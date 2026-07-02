//
//  PaywallViewModel.swift
//  TestTask
//
//  Created by Vit Chernuhin on 01.07.2026.
//

import Foundation
import Combine
@preconcurrency import XCoordinator

final class PaywallViewModel: ViewEventHandlable, ViewActionHandlable {
    
    // Внутреннее перечисление тарифов для бизнес-логики
    enum SubscriptionProduct {
        case year
        case month
    }
    
    // MARK: - Properties
    let router: WeakRouter<MainRoute>
    
    // Текущий выбранный тариф (по умолчанию Year со скидкой 80%)
    private(set) var selectedProduct: SubscriptionProduct = .year
    
    // Реактивное состояние видимости крестика для UI-слоя
    @Published private(set) var isCloseButtonVisible: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init(router: WeakRouter<MainRoute>) {
        self.router = router
    }
    
    // MARK: - Lifecycle Handler (ViewEvent)
    func handleViewEvent(_ event: ViewEvent) {
        switch event {
        case .viewDidLoad:
            startCloseButtonDelayTimer()
        }
    }
    
    // MARK: - Action Handler (PaywallAction)
    func handleAction(_ action: PaywallAction) {
        switch action {
        case .closeTapped:
            router.trigger(.dismiss)
            
        case .purchaseTapped:
            processPurchase()
            
        case .selectProduct(let product):
            self.selectedProduct = product
            print("Бизнес-логика: тариф переключен на \(product)")
        }
    }
}

// MARK: - Private Methods
private extension PaywallViewModel {
    func startCloseButtonDelayTimer() {
        Just(())
            .delay(for: .seconds(2.0), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.isCloseButtonVisible = true
            }
            .store(in: &cancellables)
    }
    
    func processPurchase() {
        print("Запуск процесса покупки в StoreKit/Apphud для тарифа: \(selectedProduct)")
    }
}
