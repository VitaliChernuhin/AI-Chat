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
    case aiChat
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
                let viewController = configureMainPageScene(router: currentRouter)
                return .push(viewController)
            }
            
        case .settings:
            return MainActor.assumeIsolated {
                let viewController = configureSettingsScene(router: currentRouter)
                return .push(viewController)
            }
            
        case .back:
            return .pop()
            
        case .aiChat:
            
            return MainActor.assumeIsolated {
                let viewController = configureAIChatScene(router: currentRouter)
                return .push(viewController)
            }
        }
    }
}

// MARK: - Scene Configurations (Global File Scope)
@MainActor
private func configureMainPageScene(router: WeakRouter<MainRoute>) -> UIViewController {
    MainPageViewController(router: router)
}

@MainActor
private func configureSettingsScene(router: WeakRouter<MainRoute>) -> UIViewController {
     SettingsViewController(router: router)
}

@MainActor
private func configureAIChatScene(router: WeakRouter<MainRoute>) -> UIViewController {
    let chatNetworkService = ServicesFactory.shared.service(type: AIChatNetworkService.self)
    let viewModel = AIChatViewModel(router: router, chatNetworkService: chatNetworkService)
    return AIChatViewController(viewModel: viewModel)
}
