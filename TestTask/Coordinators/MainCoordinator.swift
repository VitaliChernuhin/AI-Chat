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
    
    private let servicesFactory: ServicesFactory
    
    init(servicesFactory: ServicesFactory) {
        self.servicesFactory = servicesFactory
        let navigationController = MainActor.assumeIsolated {
            let nc = UINavigationController()
            nc.isNavigationBarHidden = true
            nc.interactivePopGestureRecognizer?.isEnabled = true
            return nc
        }
        super.init(rootViewController: navigationController, initialRoute: .mainPage)
    }
    
    
    nonisolated override func prepareTransition(for route: MainRoute) -> NavigationTransition {
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
        }
    }
    
    @MainActor
    private static func configureMainPageScene(router: WeakRouter<MainRoute>) -> UIViewController {
        MainPageViewController(router:router)
    }
    
    @MainActor
    private static func configureSettingsScene(router: WeakRouter<MainRoute>) -> UIViewController {
         SettingsViewController(router: router)
    }
    
    @MainActor
    private static func configureAIChatScene(router: WeakRouter<MainRoute>) -> UIViewController {
        AIChatViewController(router: router)
    }
    
}
