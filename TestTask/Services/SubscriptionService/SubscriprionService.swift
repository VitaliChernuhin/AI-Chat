//
//  SubscriptionService.swift
//  TestTask
//
//  Created by Vit Chernuhin on 02.07.2026.
//

import Foundation
import Combine
import StoreKit
import ApphudSDK

enum SubscriptionServiceError: Error, CustomStringConvertible {
    case sdkNotInitialized
    case paywallNotFound
    case productMappingFailed
    
    var description: String {
        switch self {
        case .sdkNotInitialized:
            return "Subscription SDK is not ready. Using fallback data."
        case .paywallNotFound:
            return "Paywall not found in Apphud placements."
        case .productMappingFailed:
            return "Failed to map Apphud products to local models."
        }
    }
}

protocol SubscriptionService: AnyObject {
    @MainActor var isReady: Bool { get }
    var isActive: AnyPublisher<Bool, Never> { get }
    
    @MainActor func initializeSDK()
    @MainActor func loadProducts() -> AnyPublisher<[SubscriptionProduct], Error>
    @MainActor func purchase(_ product: SubscriptionProduct) -> AnyPublisher<Bool, Error>
    @MainActor func restorePurchases() -> AnyPublisher<Bool, Error>
    @MainActor func checkActiveSubscription() -> AnyPublisher<Bool, Never>
}

final class SubscriptionServiceImpl: SubscriptionService, Logable {
    
    // MARK: - Private properties
    private let preferences: AppPreferences
    
    private lazy var mockProducts: [SubscriptionProduct] = {
        [.year(totalPrice: 69.99), .month(totalPrice: 7.99)]
    }()
    
    private let _isActive: CurrentValueSubject<Bool, Never>
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public properties
    @MainActor
    var isReady: Bool {
        Apphud.currentUser() != nil
    }
    
    var isActive: AnyPublisher<Bool, Never> {
        _isActive.eraseToAnyPublisher()
    }
    
    // MARK: - Life cycle
    init(preferences: AppPreferences) {
        self.preferences = preferences
        
        let cachedStatus = preferences.isPremiumActive
        self._isActive = CurrentValueSubject<Bool, Never>(cachedStatus)
    }
}

// MARK: - Initiliaze SDK
extension SubscriptionServiceImpl {
    @MainActor
    func initializeSDK() {
        Apphud.start(apiKey: AppConfig.apphudToken) { [weak self] user in
            guard let self = self else { return }
            self.log(message: "🎉 Apphud user registered: \(user.userId)")
        }
    }
}

// MARK: - Load products
extension SubscriptionServiceImpl {
    @MainActor
    func loadProducts() -> AnyPublisher<[SubscriptionProduct], Error> {
        Deferred {
            Future { [weak self] promise in
                guard let self = self else { return }
                
                if UIDevice.isRunningOnSimulator {
                    log(message: "Режим Симулятора. Выдаем моки напрямую...")
                    return promise(.success(self.mockProducts))
                }
                if !self.isReady {
                    return promise(.failure(SubscriptionServiceError.sdkNotInitialized))
                }
                Task { @MainActor in
                    let placements = await Apphud.placements()
                    
                    guard let placement = placements.first(where: {
                        $0.identifier == AppConfig.apphudPaywallId
                        || $0.paywall?.identifier == AppConfig.apphudPaywallId
                    }),let paywall = placement.paywall
                    else {
                        let error = SubscriptionServiceError.paywallNotFound
                        return promise(.failure(error))
                    }
                    
                    Apphud.paywallShown(paywall)
                    
                    let mappedProducts = paywall.products.compactMap { apphudProd in
                        mapApphudProduct(to: apphudProd)
                    }
                    
                    if mappedProducts.isEmpty {
                        log(message: "Не удалось замаппить ни одного продукта")
                        return promise(.failure(SubscriptionServiceError.productMappingFailed))
                    }
                    promise(.success(mappedProducts))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}


// MARK: - Purchase product
extension SubscriptionServiceImpl {
    @MainActor
    func purchase(_ product: SubscriptionProduct) -> AnyPublisher<Bool, Error> {
        Deferred {
            Future { promise in
                if UIDevice.isRunningOnSimulator {
                    Task { @MainActor in
                        let idString = product.isYearly ? "yearly_subscription" : "monthly_subscription"
                        self.log(message: "🤖 Симулятор: Запуск нативного окна StoreKit для ID: \(idString)")
                        
                        if let appProduct = try? await Product.products(for: [idString]).first {
                            do {
                                let result = try await appProduct.purchase()
                                switch result {
                                case .success(let verification):
                                    if case .verified = verification {
                                        promise(.success(true))
                                        // ВАЖНО: после успешной покупки обновляем поток статуса
                                        _ = Task { @MainActor in
                                            let isActive = await self.computeIsActiveFromTransactions()
                                            self.updatePremiumStatus(isActive)
                                        }
                                    } else {
                                        promise(.success(false))
                                    }
                                case .userCancelled:
                                    self.log(message: "⚠️ Пользователь отменил покупку")
                                    promise(.success(false))
                                case .pending:
                                    promise(.success(false))
                                @unknown default:
                                    promise(.success(false))
                                }
                            } catch {
                                promise(.failure(error))
                            }
                        } else {
                            promise(.success(true))
                        }
                    }
                    return
                }
                
                if !self.isReady {
                    return promise(.failure(SubscriptionServiceError.sdkNotInitialized))
                }
                
                Task { @MainActor in
                    let placements = await Apphud.placements()
                    guard let paywall = placements.first(where: { $0.identifier == AppConfig.apphudPaywallId || $0.paywall?.identifier == AppConfig.apphudPaywallId })?.paywall
                    else {
                        promise(.failure(SubscriptionServiceError.paywallNotFound))
                        return
                    }
                    guard let apphudProduct = self.searchApphudProduct(apphudProducts: paywall.products, by: product)
                    else {
                        promise(.success(false))
                        return
                    }
                    
                    let result = await Apphud.purchase(apphudProduct)
                    promise(.success(result.success))
                    
                    // ВАЖНО: после покупки через Apphud тоже обновляем статус
                    if result.success {
                        _ = Task { @MainActor in
                            self.updatePremiumStatus(Apphud.hasActiveSubscription())
                        }
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Restore purchases
extension SubscriptionServiceImpl {
    @MainActor
    func restorePurchases() -> AnyPublisher<Bool, Error> {
        Deferred {
            Future { promise in
                if UIDevice.isRunningOnSimulator {
                    Task { @MainActor in
                        do {
                            self.log(message: "🤖 Симулятор: Запрос нативного восстановления чеков в Apple StoreKit...")
                            try await AppStore.sync()
                            
                            var hasActiveSubscription = false
                            for await status in Transaction.currentEntitlements {
                                if case .verified(let transaction) = status {
                                    if transaction.productID == "yearly_subscription" ||
                                        transaction.productID == "monthly_subscription" {
                                        hasActiveSubscription = true
                                    }
                                }
                            }
                            
                            promise(.success(hasActiveSubscription))
                            
                            // ВАЖНО: после рестора тоже обновляем поток
                            _ = Task { @MainActor in
                                let isActive = await self.computeIsActiveFromTransactions()
                                self.updatePremiumStatus(isActive)
                            }
                        } catch {
                            promise(.failure(error))
                        }
                    }
                    return
                }
                
                if !self.isReady {
                    return promise(.failure(SubscriptionServiceError.sdkNotInitialized))
                }
                Task { @MainActor in
                    do {
                        let result = await Apphud.restorePurchases()
                        promise(.success(result?.success ?? false))
                        
                        // ВАЖНО: обновляем статус после рестора
                        if result?.success == true {
                            _ = Task { @MainActor in
                                self.updatePremiumStatus(Apphud.hasActiveSubscription())
                            }
                        }
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Check active subscription
extension SubscriptionServiceImpl {
    @MainActor
    func checkActiveSubscription() -> AnyPublisher<Bool, Never> {
        Deferred {
            Future { promise in
                // 1. РЕЖИМ СИМУЛЯТОРА: Проверяем локальные права StoreKit 2 на лету
                if UIDevice.isRunningOnSimulator {
                    Task { @MainActor in
                        var isActive = false
                        for await status in Transaction.currentEntitlements {
                            if case .verified(let transaction) = status {
                                if transaction.productID == "yearly_subscription" ||
                                    transaction.productID == "monthly_subscription" {
                                    isActive = true
                                }
                            }
                        }
                        self.updatePremiumStatus(isActive)
                        promise(.success(isActive))
                    }
                    return
                }
                
                let hasPremium = Apphud.hasActiveSubscription()
                self.updatePremiumStatus(hasPremium)
                promise(.success(hasPremium))
            }
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Update premium status (private)
private extension SubscriptionServiceImpl {
    func updatePremiumStatus(_ isActive: Bool) {
        self._isActive.value = isActive
        
        // Передаем значение в преференсы одной строчкой без хардкода ключей! ✨
        self.preferences.isPremiumActive = isActive
        self.log(message: "💾 Преференсы приложения синхронизированы. Премиум: \(isActive)")
    }
}

// MARK: - Apphud product methods (private)
private extension SubscriptionServiceImpl {
    func mapApphudProduct(to apphudProd: ApphudProduct) -> SubscriptionProduct? {
        let productId = apphudProd.productId.lowercased()
        let rawPrice = apphudProd.skProduct?.price.doubleValue
        
        if productId.hasSuffix("yearly") || productId.hasSuffix("1y") || productId.contains("year") {
            let price = rawPrice ?? 69.99
            return .year(totalPrice: price)
        } else if productId.hasSuffix("monthly") || productId.hasSuffix("1m") || productId.contains("month") {
            let price = rawPrice ?? 7.99
            return .month(totalPrice: price)
        }
        return nil
    }
    
    func searchApphudProduct(apphudProducts:[ApphudProduct], by product: SubscriptionProduct) -> ApphudProduct? {
        if product.isYearly {
            return apphudProducts.first { $0.productId.hasSuffix("yearly") || $0.productId.hasSuffix("1y") || $0.productId.contains("year") }
        } else {
            return apphudProducts.first { $0.productId.hasSuffix("monthly") || $0.productId.hasSuffix("1m") || $0.productId.contains("month") }
        }
    }
}

// MARK: - For simulator transactions methods (private)
private extension SubscriptionServiceImpl {
    @MainActor
    func computeIsActiveFromTransactions() async -> Bool {
            for await status in Transaction.currentEntitlements {
                if case .verified(let transaction) = status,
                   ["yearly_subscription", "monthly_subscription"].contains(transaction.productID) {
                    return true
                }
            }
            return false
        }
}


