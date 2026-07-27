//
//  PaywallAction.swift
//  TestTask
//
//  Created by Vit Chernuhin on 01.07.2026.
//

import Foundation

// MARK: - Paywall Actions
enum PaywallAction {
    case closeTapped
    case purchaseTapped
    case selectProduct(SubscriptionProduct)
    case privatePolicyTapped
    case restoreTapped
    case termsOfUseTapped
}
