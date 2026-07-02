//
//  NavigationBarOwner.swift
//  TestTask
//
//  Created by Vit Chernuhin on 24.06.2026.
//


import UIKit
import XCoordinator

protocol NavigationBarOwner: UIViewController {
    var navigationBar: AppNavigationBar { get }
    
    func backButtonTapped()
}

extension NavigationBarOwner {
    
    func backButtonTapped() {}
    
    func setupNavBarActions() {
        navigationBar.onBackTapped = { [weak self] in
            self?.backButtonTapped()
        }
    }
}

extension NavigationBarOwner where Self: Routable, Self.TargetRoute == MainRoute {
    
    func setupAutomaticBackNavigation() {
        navigationBar.onBackTapped = { [weak self] in
            self?.router.trigger(.back)
        }
    }
}
