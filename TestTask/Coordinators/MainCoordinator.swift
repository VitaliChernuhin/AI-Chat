//
//  MainCoordinator.swift
//  TestTask
//
//  Created by Vit Chernuhin on 20.06.2026.
//

import UIKit
import Combine
@preconcurrency import XCoordinator

enum MainRoute: Route {
    case mainPage
    case settings
    case back
    case aiChat
    case alert(type: AppAlertView.AlertType, message: String)
    case dismiss
    case dismissAfterAlert(type: AppAlertView.AlertType, message: String)
    case paywall
    
    case openPrivacy
    case openTerms
}

final class MainCoordinator: NavigationCoordinator<MainRoute> {
    
    private var cancellables = Set<AnyCancellable>()
    private let alertTime = 2.5
    
    init() {
        let navigationController = MainActor.assumeIsolated {
            let nc = UINavigationController()
            nc.isNavigationBarHidden = true
            nc.interactivePopGestureRecognizer?.isEnabled = true
            return nc
        }
        super.init(rootViewController: navigationController, initialRoute: .mainPage)
    }
    
    override func prepareTransition(for route: MainRoute) -> NavigationTransition {
        let currentRouter = self.weakRouter
        
        switch route {
        case .mainPage:
            return MainActor.assumeIsolated {
                let viewController = Self.configureMainPageScene(router: currentRouter)
                return .push(viewController)
            }
            
        case .settings:
            return MainActor.assumeIsolated {
                let viewController = Self.configureSettingsScene(router: currentRouter)
                return .push(viewController)
            }
            
        case .back:
            return .pop()
            
        case .aiChat:
            
            return MainActor.assumeIsolated {
                let viewController = Self.configureAIChatScene(router: currentRouter)
                return .push(viewController)
            }
            
        case .alert(let type, let message):
            let router = currentRouter
            
            let subscription = Just(())
                .delay(for: .seconds(alertTime), scheduler: DispatchQueue.main)
                .sink { _ in
                    router.trigger(.dismiss)
                }
            
            self.cancellables.insert(subscription)
            
            let transition: NavigationTransition = MainActor.assumeIsolated {
                let viewController = Self.configureAppAlertScene(type: type, message: message)
                viewController.modalPresentationStyle = .overFullScreen
                
                let customAnimation = Animation(
                    presentation: AppAlertTransitionAnimation(isPresenting: true),
                    dismissal: AppAlertTransitionAnimation(isPresenting: false)
                )
                
                return .present(viewController, animation: customAnimation)
            }
            return transition
            
        case .dismiss:
            return .dismiss()
            
        case .dismissAfterAlert(let type, let message):
            let router = currentRouter
            
            let subscription = Just(())
                .delay(for: .seconds(alertTime), scheduler: DispatchQueue.main)
                .sink { _ in
                    router.trigger(.dismiss) {
                        router.trigger(.dismiss)
                    }
                }
            self.cancellables.insert(subscription)
            
            return MainActor.assumeIsolated {
                let viewController = Self.configureAppAlertScene(type: type, message: message)
                viewController.modalPresentationStyle = .overFullScreen
                
                let customAnimation = Animation(
                    presentation: AppAlertTransitionAnimation(isPresenting: true),
                    dismissal: AppAlertTransitionAnimation(isPresenting: false)
                )
                
                // Презентуем алерт на экран
                return .present(viewController, animation: customAnimation)
            }
            
        case .paywall:
            return MainActor.assumeIsolated {
                let viewController = Self.configurePaywallScene(router: currentRouter)
                // Настраиваем системную или кастомную анимацию выезда снизу вверх
                
                viewController.modalPresentationStyle = .fullScreen
                viewController.modalTransitionStyle = .coverVertical // Нативный выезд снизу вверх
                
                return .present(viewController)
            }
            
        case .openPrivacy:
            return MainActor.assumeIsolated {
                UIApplication.shared.open(AppConfig.privacyURL, options: [:], completionHandler: nil)
                return .none()
            }
            
        case .openTerms:
            return MainActor.assumeIsolated {
                UIApplication.shared.open(AppConfig.termsURL, options: [:])
                return .none()
            }
        }
    }
    
    // MARK: - Scene Configurations (private)
    @MainActor
    private static func configureMainPageScene(router: WeakRouter<MainRoute>) -> UIViewController {
        MainPageViewController(router: router)
    }
    
    @MainActor
    private static func configureSettingsScene(router: WeakRouter<MainRoute>) -> UIViewController {
        SettingsViewController(router: router)
    }
    
    @MainActor
    private static func configureAIChatScene(router: WeakRouter<MainRoute>) -> UIViewController {
        let chatNetworkService = ServicesFactory.shared.service(type: AIChatNetworkService.self)
        let viewModel = AIChatViewModel(router: router, chatNetworkService: chatNetworkService)
        return AIChatViewController(viewModel: viewModel)
    }
    
    @MainActor
    private static func configureAppAlertScene(type: AppAlertView.AlertType, message: String) -> UIViewController {
        AppAlertViewController(type: type, message: message)
    }
    
    @MainActor
    private static func configurePaywallScene(router: WeakRouter<MainRoute>) -> UIViewController {
        let viewModel = PaywallViewModel(router: router, subscriptionService: ServicesFactory.shared.service(type: SubscriptionService.self))
        return PaywallViewController(viewModel: viewModel)
    }
}
