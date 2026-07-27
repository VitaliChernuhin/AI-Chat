//
//  MainCoordinator.swift
//  TestTask
//
//  Created by Vit Chernuhin on 20.06.2026.
//

import UIKit
@preconcurrency import XCoordinator

enum MainRoute: Route {
    case mainPage
    case settings
    case back
    case aiChat(launchContext: ChatLaunchContext)
    case aiChatsHistory
    case alert(type: AppAlertView.AlertType, message: String)
    case dismiss
    case paywall
    case fixImproveText
    case summarizeText
    case generateVideo
    
    case openPrivacy
    case openTerms
}

final class MainCoordinator: NavigationCoordinator<MainRoute> {
    
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
            
        case .aiChat(launchContext: let launchContext):
            return MainActor.assumeIsolated {
                let viewController = Self.configureAIChatScene(router: currentRouter, launchContext: launchContext)
                return .push(viewController)
            }
            
        case .aiChatsHistory:
            return MainActor.assumeIsolated {
                let viewController = Self.configureAIChatsScene(router: currentRouter)
                return .push(viewController)
            }
            
        case .alert(let type, let message):
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
        
        case .paywall:
            return MainActor.assumeIsolated {
                let viewController = Self.configurePaywallScene(router: currentRouter)
                viewController.modalPresentationStyle = .fullScreen
                viewController.modalTransitionStyle = .coverVertical
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
        
        case .fixImproveText:
            return MainActor.assumeIsolated {
                let viewController = Self.configureFixImproveTextScene(router: currentRouter)
                return .push(viewController)
            }
            
        case .summarizeText:
            return MainActor.assumeIsolated {
                let viewController = Self.configureSummarizeTextScene(router: currentRouter)
                return .push(viewController)
            }
            
        case .generateVideo:
            return MainActor.assumeIsolated {
                let viewController = Self.configureGenerateVideoScene(router: currentRouter)
                return .push(viewController)
            }
        }
    }
}

// MARK: - Scenes Configurations (private)
private extension MainCoordinator {
    @MainActor
    static func configureMainPageScene(router: WeakRouter<MainRoute>) -> UIViewController {
        let viewModel = MainPageViewModel(router: router, subscriptionService: ServicesFactory.shared.service(type: SubscriptionService.self))
        return MainPageViewController(viewModel: viewModel)
    }
    
    @MainActor
    static func configureSettingsScene(router: WeakRouter<MainRoute>) -> UIViewController {
        ComingSoonViewController(router: router, title: "Settings")
    }
    
    @MainActor
    static func configureAIChatScene(router: WeakRouter<MainRoute>, launchContext: ChatLaunchContext) -> UIViewController {
        let chatNetworkService = ServicesFactory.shared.service(type: AIChatNetworkService.self)
        let viewModel = AIChatViewModel(router: router, chatNetworkService: chatNetworkService, launchContext: launchContext)
        return AIChatViewController(viewModel: viewModel)
    }
    
    @MainActor
    static func configureAIChatsScene(router: WeakRouter<MainRoute>) -> UIViewController {
        let viewModel = AIChatsHistoryViewModel(router: router, chatNetworkService: ServicesFactory.shared.service(type: AIChatNetworkService.self))
        return AIChatsHistoryViewController(viewModel: viewModel)
    }
    
    @MainActor
    static func configureFixImproveTextScene(router: WeakRouter<MainRoute>) -> UIViewController {
        ComingSoonViewController(router: router, title: "Fix and improve writing")
    }
    
    @MainActor
    static func configureSummarizeTextScene(router: WeakRouter<MainRoute>) -> UIViewController {
        ComingSoonViewController(router: router, title: "Summarize")
    }
    
    @MainActor
    static func configureGenerateVideoScene(router: WeakRouter<MainRoute>) -> UIViewController {
        ComingSoonViewController(router: router, title: "Turn Photo into Video")
    }
    
    @MainActor
    static func configureAppAlertScene(type: AppAlertView.AlertType, message: String) -> UIViewController {
        AppAlertViewController(type: type, message: message)
    }
    
    @MainActor
    static func configurePaywallScene(router: WeakRouter<MainRoute>) -> UIViewController {
        let viewModel = PaywallViewModel(router: router, subscriptionService: ServicesFactory.shared.service(type: SubscriptionService.self))
        return PaywallViewController(viewModel: viewModel)
    }
}
