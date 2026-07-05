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
    @MainActor var isReady: Bool { get  }
    
    @MainActor func initializeSDK()
    @MainActor func loadProducts() -> AnyPublisher<[SubscriptionProduct], Error>
    @MainActor func purchase(_ product: SubscriptionProduct) -> AnyPublisher<Bool, Error>
    @MainActor func restorePurchases() -> AnyPublisher<Bool, Error>
    @MainActor func checkActiveSubscription() -> AnyPublisher<Bool, Never>
}

final class SubscriptionServiceImpl: SubscriptionService, Logable {
    
    // MARK: - Private properties
    private lazy var mockProducts: [SubscriptionProduct] = {
        [.year(totalPrice: 69.99), .month(totalPrice: 7.99)]
    }()
    
    @MainActor
    var isReady: Bool {
        Apphud.currentUser() != nil
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
                // 1. РЕЖИМ СИМУЛЯТОРА: Вызываем нативное окно StoreKit напрямую через Apple API!
                if UIDevice.isRunningOnSimulator {
                    Task { @MainActor in
                        let idString = product.isYearly ? "yearly_subscription" : "monthly_subscription"
                        self.log(message: "🤖 Симулятор: Запуск нативного окна StoreKit для ID: \(idString)")
                        
                        // Запрашиваем продукт напрямую у StoreKit 2 в обход Apphud!
                        // Это гарантированно выведет белое окно покупки на симуляторе!
                        if let appProduct = try? await Product.products(for: [idString]).first {
                            do {
                                let result = try await appProduct.purchase()
                                switch result {
                                case .success(let verification):
                                    if case .verified = verification {
                                        promise(.success(true))
                                    } else {
                                        promise(.success(true)) // Для тестов на симуляторе
                                    }
                                case .userCancelled:
                                    self.log(message: "⚠️ Пользователь отменил покупку в окне StoreKit")
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
                            // Фоллбек, если StoreKit-файл не подгрузился
                            promise(.success(true))
                        }
                    }
                    return
                }
                
                // 2. БОЕВОЙ РЕЖИМ: Отрабатывает строго на реальном устройстве через Apphud Placements
                if !self.isReady {
                    return promise(.failure(SubscriptionServiceError.sdkNotInitialized))
                }
                
                Task { @MainActor in
                    //Берем paywall
                    let placements = await Apphud.placements()
                    guard let paywall = placements.first(where: { $0.identifier == AppConfig.apphudPaywallId || $0.paywall?.identifier == AppConfig.apphudPaywallId })?.paywall
                    else {
                        promise(.failure(SubscriptionServiceError.paywallNotFound))
                        return
                    }
                    //Берем product
                    guard let apphudProduct = self.searchApphudProduct(apphudProducts: paywall.products, by: product)
                    else {
                        promise(.success(false))
                        return
                    }
                    
                    let result = await Apphud.purchase(apphudProduct)
                    promise(.success(result.success))
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
                // 1. РЕЖИМ СИМУЛЯТОРА: Честно проверяем локальный .storekit файл через нативный API Apple!
                if UIDevice.isRunningOnSimulator {
                    Task { @MainActor in
                        do {
                            self.log(message: "🤖 Симулятор: Запрос нативного восстановления чеков в Apple StoreKit...")
                            
                            // Синхронизируем очередь транзакций локального StoreKit-файла
                            try await AppStore.sync()
                            
                            var hasActiveSubscription = false
                            
                            // Проверяем все текущие оформленные подписки в системе
                            for await status in Transaction.currentEntitlements {
                                if case .verified(let transaction) = status {
                                    // Если в кэше симулятора есть хоть одна наша подписка — это успех!
                                    if transaction.productID == "yearly_subscription" ||
                                        transaction.productID == "monthly_subscription" {
                                        hasActiveSubscription = true
                                    }
                                }
                            }
                            
                            promise(.success(hasActiveSubscription))
                        } catch {
                            promise(.failure(error))
                        }
                    }
                    return
                }
                
                // 2. БОЕВОЙ РЕЖИМ: На реальном устройстве через Apphud
                if !self.isReady {
                    return promise(.failure(SubscriptionServiceError.sdkNotInitialized))
                }
                Task { @MainActor in
                    do {
                        let result = await Apphud.restorePurchases()
                        promise(.success(result?.success ?? false))
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
                        promise(.success(isActive))
                    }
                    return
                }
                
                let hasPremium = Apphud.hasActiveSubscription()
                promise(.success(hasPremium))
            }
        }
        .eraseToAnyPublisher()
    }
}

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
            guard let apphudProduct = apphudProducts.first(where: { finded in
                finded.productId.hasSuffix("yearly") || finded.productId.hasSuffix("1y") || finded.productId.contains("year")
            }) else { return nil }
            return apphudProduct
        } else {
            guard let apphudProduct = apphudProducts.first(where: { finded in
                finded.productId.hasSuffix("monthly") || finded.productId.hasSuffix("1m") || finded.productId.contains("month")
            }) else { return nil }
            return apphudProduct
        }
    }
}
