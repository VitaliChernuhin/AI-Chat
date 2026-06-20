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
}

final class MainCoordinator: NavigationCoordinator<MainRoute> {
    
    private let servicesFactory: ServicesFactory
    
    init(servicesFactory: ServicesFactory) {
        self.servicesFactory = servicesFactory
        let navigationController = MainActor.assumeIsolated {
            let nc = UINavigationController()
            nc.isNavigationBarHidden = true
            return nc
        }
        super.init(rootViewController: navigationController, initialRoute: .mainPage)
    }
    
    
    nonisolated override func prepareTransition(for route: MainRoute) -> NavigationTransition {
        switch route {
        case .mainPage:
            return MainActor.assumeIsolated {
                let viewController = Self.createMainPageViewController()
                return .push(viewController)
            }
        }
    }
    
    @MainActor
    private static func createMainPageViewController() -> MainPageViewController {
        return MainPageViewController()
    }
}
