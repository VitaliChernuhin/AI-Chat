//
//  PaywallViewModel.swift
//  TestTask
//
//  Created by Vit Chernuhin on 01.07.2026.
//

import Foundation
import Combine
@preconcurrency import XCoordinator

@MainActor
final class PaywallViewModel: Logable {
    
    // MARK: - Properties
    let router: WeakRouter<MainRoute>
    private let subscriptionService: SubscriptionService
    
    // Выбранный по умолчанию продукт (Yearly со скидкой)
    private(set) var selectedProduct: SubscriptionProduct = .year(totalPrice: 69.99)
    
    // Реактивные стейты для UI-слоя
    @Published private(set) var uiModels: [ProductUIModel] = []
    @Published private(set) var isCloseButtonVisible: Bool = false
    @Published private(set) var isPurchasing: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init(router: WeakRouter<MainRoute>, subscriptionService: SubscriptionService) {
        self.router = router
        self.subscriptionService = subscriptionService
        
        setupInitialUIModels()
    }
}

// MARK: - ViewEventHandable (implementation)
extension PaywallViewModel {
    func handleViewEvent(_ event: ViewEvent) {
        switch event {
        case .viewDidLoad:
            startCloseButtonDelayTimer()
            loadProducts()
        }
    }
}

// MARK: - ViewActionHandable (Действия пользователя)
extension PaywallViewModel {
    
    func handleAction(_ action: PaywallAction) {
        guard !isPurchasing else { return }
        
        switch action {
        case .closeTapped:
            router.trigger(.dismiss)
            
        case .purchaseTapped:
            executePurchase()
            
        case .selectProduct(let product):
            self.selectedProduct = product
            
            for index in 0..<uiModels.count {
                uiModels[index].isSelected = (uiModels[index].product == product)
            }
            self.log(message: "📱 Выбран продукт: \(product)")
            
        case .restoreTapped:
            // Вызываем наш готовый приватный метод реактивного восстановления!
            restorePurchases()
            
        case .privatePolicyTapped:
            self.log(message: "🌐 Пользователь запросил Privacy Policy. Открываем Safari...")
            // Здесь в будущем дергаем роут координатора для открытия WebViewController или системного Safari
            // router.trigger(.openURL(AppConfig.privacyURL))
            
        case .termsOfUseTapped:
            self.log(message: "🌐 Пользователь запросил Terms of Use. Открываем Safari...")
            // router.trigger(.openURL(AppConfig.termsURL))
        }
    }
}

// MARK: - Private Methods
private extension PaywallViewModel {
    
    func startCloseButtonDelayTimer() {
        Just(true)
            .delay(for: .seconds(2.0), scheduler: DispatchQueue.main)
            .sink { [weak self] isVisible in
                self?.isCloseButtonVisible = isVisible
            }
            .store(in: &cancellables)
    }
    
    func setupInitialUIModels() {
        uiModels = [ ProductUIModel(product: .year(totalPrice: 59.99), isSelected: true, badge: "SAVE 80%"), ProductUIModel(product: .month(totalPrice: 4.99), isSelected: false) ]
    }
}

// MARK: - Load products (private)
private extension PaywallViewModel {
    func loadProducts() {
        subscriptionService.loadProducts()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                if case .failure(let error) = completion {
                    self.log(message: "❌ Не удалось загрузить актуальные цены из Apphud: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] actualProducts in
                guard let self = self else { return }
                guard !actualProducts.isEmpty else { return }
                
                self.uiModels = actualProducts.map { apphudProduct in
                    ProductUIModel(
                        product: apphudProduct,
                        isSelected: (apphudProduct == self.selectedProduct),
                        badge: apphudProduct.badgeText
                    )
                }
                
                self.log(message: "✅ UI-модели успешно обновлены реальными данными из Apphud!")
            }
            .store(in: &cancellables)
    }
}

// MARK: - Execute purchases (private)
private extension PaywallViewModel {
    func executePurchase() {
        guard let selectedProduct = uiModels.first(where: { $0.isSelected })?.product else { return }
        
        subscriptionService.purchase(selectedProduct)
            .receive(on: DispatchQueue.main)
            .handleEvents(
                receiveSubscription: { [weak self] _ in
                    self?.isPurchasing = true
                },
                receiveCompletion: { [weak self] _ in
                    self?.isPurchasing = false
                }
            )
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.log(message: "❌ Ошибка транзакции: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] isSuccess in
                guard let self = self else { return }
                
                if isSuccess {
                    self.log(message: "🎉 Транзакция прошла успешно, закрываем пейволл!")
                    self.router.trigger(.dismiss)
                } else {
                    self.log(message: "⚠️ Транзакция была отменена пользователем или прервана.")
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Restore purchases (private)
private extension PaywallViewModel {
    func restorePurchases() {
        guard !isPurchasing else { return }
        
        subscriptionService.restorePurchases()
            .receive(on: DispatchQueue.main)
            .handleEvents(
                receiveSubscription: { [weak self] _ in
                    self?.isPurchasing = true
                },
                receiveCompletion: { [weak self] _ in
                    self?.isPurchasing = false
                }
            )
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.log(message: "❌ Ошибка восстановления: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] isSuccess in
                guard let self = self else { return }
                
                if isSuccess {
                    self.log(message: "🎉 Покупки успешно восстановлены!")
                    self.router.trigger(.dismiss)
                } else {
                    self.log(message: "⚠️ Восстанавливать нечего на этом аккаунте.")
                }
            }
            .store(in: &cancellables)
    }
}

