//
//  MainPageViewModel.swift
//  TestTask
//
//  Created by Vit Chernuhin on 04.07.2026.
//

import Foundation
import Combine
@preconcurrency import XCoordinator

@MainActor
final class MainPageViewModel: ViewEventHandlable, ViewActionHandlable, Logable {
    
    // MARK: - Properties
    private let router: WeakRouter<MainRoute>
    private let subscriptionService: SubscriptionService
    
    let features: [FeatureItem] = [
        FeatureItem(type: .turnPhotoToVideo),
        FeatureItem(type: .fixWriting),
        FeatureItem(type: .summarize)
    ]

    @Published private(set) var isPremiumActive: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init(router: WeakRouter<MainRoute>, subscriptionService: SubscriptionService) {
        self.router = router
        self.subscriptionService = subscriptionService
    }
}

// MARK: - ViewEventHandable (implementation)
extension MainPageViewModel {
    func handleViewEvent(_ event: ViewEvent) {
        switch event {
        case .viewDidLoad:
            bindSubscriptionStatus()
        }
    }
}

// MARK: - ViewActionHandable (implementation)
extension MainPageViewModel {
    func handleAction(_ action: MainPageAction) {
        switch action {
        case .aiChatTapped:
            self.log(message: "💬 Пользователь нажал на прямой вход в AI Chat.")
            router.trigger(.aiChat)
            
        case .featureTapped(let type):
            if !isPremiumActive {
                self.log(message: "🔒 Фича \(type) заблокирована. Открываем Premium Paywall...")
                router.trigger(.paywall)
            } else {
                self.log(message: "🔓 Премиум активен! Запускаем боевой экран для \(type)")
                switch type {
                case .turnPhotoToVideo:
                    print("🚀 Переход на боевой экран: Анимация Фото -> Видео")
                case .fixWriting:
                    print("🚀 Переход на боевой экран: Улучшение текста и грамматики")
                case .summarize:
                    router.trigger(.aiChat)
                }
            }
            
        case .settingsTapped:
            router.trigger(.settings)
        }
    }
}

// MARK: - Private methods
private extension MainPageViewModel {
    func bindSubscriptionStatus() {
        subscriptionService.checkActiveSubscription()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isPremiumActive in
                guard let self = self else { return }
                
                self.isPremiumActive = isPremiumActive
                self.log(message: "📱 Стейт подписки на главном экране обновлен: \(isPremiumActive)")
            }
            .store(in: &cancellables)
    }
    
}
