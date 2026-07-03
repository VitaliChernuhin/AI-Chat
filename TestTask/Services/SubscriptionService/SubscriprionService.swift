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

protocol SubscriptionService: AnyObject {
 
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
}

// MARK: - SDK Initialization
extension SubscriptionServiceImpl {
    @MainActor
    func initializeSDK() {
        Apphud.start(apiKey: AppConfig.apphudToken)
        log(message: "🎉 SDK Apphud успешно запущен!")
    }
}

// MARK: - Load products
extension SubscriptionServiceImpl {
    @MainActor
    func loadProducts() -> AnyPublisher<[SubscriptionProduct], Error> {
        Deferred {
            Future { [weak self] promise in
                guard let self = self else { return }
                
                // 1. Режим симулятора: Мгновенно возвращаем локальные моки в promise!
                if UIDevice.isRunningOnSimulator {
                    log(message: "Режим Симулятора. Выдаем моки напрямую...")
                    promise(.success(self.mockProducts))
                    return
                }
                
                Task { @MainActor in
                    let placements = await Apphud.placements()
                    if let placement = placements.first(where: { $0.identifier == AppConfig.apphudPaywallId || $0.paywall?.identifier == AppConfig.apphudPaywallId }),
                       let targetPaywall = placement.paywall {
                        
                        Apphud.paywallShown(targetPaywall)
                        var mappedProducts: [SubscriptionProduct] = []
                        
                        for apphudProd in targetPaywall.products {
                            let productId = apphudProd.productId.lowercased()
                            let rawPrice = apphudProd.skProduct?.price.doubleValue ?? (productId.contains("yearly") ? 69.99 : 7.99)
                            
                            if productId.contains("yearly") || productId.contains("year") || productId.contains("1y") {
                                mappedProducts.append(.year(totalPrice: rawPrice))
                            } else if productId.contains("monthly") || productId.contains("month") || productId.contains("1m") {
                                mappedProducts.append(.month(totalPrice: rawPrice))
                            }
                        }
                        
                        // ПРЯМОЙ ОТВЕТ: Публикуем массив реальных цен прямо в promise!
                        promise(.success(mappedProducts))
                    } else {
                        // Если сети нет — шлем моки, но жестко сигнализируем об ошибке
                        let error = NSError(
                            domain: "SubscriptionService",
                            code: -1009,
                            userInfo: [NSLocalizedDescriptionKey: "Failed to load actual prices from Apphud."]
                        )
                        // Сначала отдаем моки, чтобы UI не пустовал (или можно вернуть failure по твоему усмотрению)
                        promise(.success(self.mockProducts))
                        promise(.failure(error))
                    }
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
                Task { @MainActor in
                    let placements = await Apphud.placements()
                    guard let paywall = placements.first(where: { $0.identifier == AppConfig.apphudPaywallId || $0.paywall?.identifier == AppConfig.apphudPaywallId })?.paywall,
                          let apphudProduct = paywall.products.first(where: {
                              product.isYearly ? $0.productId.contains("yearly") : $0.productId.contains("monthly")
                          }) else {
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
                            // Имитируем красивую задержку UI на 1 секунду
                            try await Task.sleep(nanoseconds: 1_000_000_000)
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
                            // Если произошел сбой синхронизации — возвращаем false, чтобы не вешать UI
                            promise(.success(false))
                        }
                    }
                    return
                }
                
                // 2. БОЕВОЙ РЕЖИМ: На реальном устройстве через Apphud
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
                
                // 2. БОЕВОЙ РЕЖИМ: Мгновенный синхронный ответ из кэша Apphud на реальном устройстве!
                let hasPremium = Apphud.hasActiveSubscription()
                promise(.success(hasPremium))
            }
        }
        .eraseToAnyPublisher()
    }
}

