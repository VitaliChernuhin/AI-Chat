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
final class PaywallViewModel {
    
    // MARK: - Properties
    let router: WeakRouter<MainRoute>
    private let subscriptionService: SubscriptionService
    
    @Published private(set) var uiModels: [ProductUIModel] = []
    @Published private(set) var isCloseButtonVisible: Bool = false
    @Published private(set) var isPurchasing: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init(router: WeakRouter<MainRoute>, subscriptionService: SubscriptionService) {
        self.router = router
        self.subscriptionService = subscriptionService
        
        setupInitialUIModels()
        bindSubscriptionService()
    }
    
    // MARK: - Public Methods
    func restorePurchases() {
        guard !isPurchasing else { return }
        Task {
            do {
                let success = try await subscriptionService.restorePurchases()
                if success {
                    print("Бизнес-логика: Покупки успешно восстановлены!")
                    await router.trigger(.dismiss)
                }
            } catch {
                print("Бизнес-логика: Ошибка восстановления: \(error.localizedDescription)")
            }
        }
    }
    
}

// MARK: - ViewEventHandable (implementation)
extension PaywallViewModel {
    func handleViewEvent(_ event: ViewEvent) {
        switch event {
        case .viewDidLoad:
            startCloseButtonDelayTimer()
        }
    }
}

// MARK: - ViewActionHandable (implementation)
extension PaywallViewModel {
    func handleAction(_ action: PaywallAction) {
        guard !isPurchasing else { return }
        
        switch action {
        case .closeTapped:
            router.trigger(.dismiss)
            
        case .purchaseTapped:
            Task { await executePurchase() }
            
        case .selectProduct(let productType):// [^1]
            // Пересчитываем стейт выделения
            for index in 0..<uiModels.count {
                uiModels[index].isSelected = (uiModels[index].type == productType)
            }
            print("Бизнес-логика: выбран продукт \(productType)")
        }
    }
}

// MARK: - Private methods
private extension PaywallViewModel {
    
    func startCloseButtonDelayTimer() {
        Just(true)
            .delay(for: .seconds(2.0), scheduler: DispatchQueue.main)
            .assign(to: \.isCloseButtonVisible, on: self)
            .store(in: &cancellables)
    }
    
    func setupInitialUIModels() {
        uiModels = [
            ProductUIModel(type: .year, title: "Yearly Access", price: "$59.99/yr", badge: "SAVE 80%", isSelected: true),
            ProductUIModel(type: .month, title: "Monthly Access", price: "$4.99/mo", badge: nil, isSelected: false)
        ]
    }
    
    func bindSubscriptionService() {
        subscriptionService.isPurchasing
            .receive(on: DispatchQueue.main)
            .assign(to: \.isPurchasing, on: self)
            .store(in: &cancellables)
    }
    
    func executePurchase() async {
        guard let selectedProductType = uiModels.first(where: { $0.isSelected })?.type else { return }
        
        do {
            let success = try await subscriptionService.purchase(selectedProductType)
            if success {
                await router.trigger(.dismiss)
            }
        } catch {
            print("Бизнес-логика: Ошибка транзакции: \(error.localizedDescription)")
        }
    }
}
