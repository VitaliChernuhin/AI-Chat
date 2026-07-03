//
//  SubscriptionProduct.swift
//  TestTask
//
//  Created by Vit Chernuhin on 02.07.2026.
//

import Foundation

enum SubscriptionProduct {
    
    case year(totalPrice: Double)
    case month(totalPrice: Double)
    
    var title: String {
        switch self {
        case .year(let price):
            let weekly = price / 52.0
            let formattedWeekly = String(format: "%.2f", weekly)
            return "Year $\(formattedWeekly) / week"
            
        case .month(let price):
            let weekly = price / 4.0
            let formattedWeekly = String(format: "%.2f", weekly)
            return "Month $\(formattedWeekly) / week"
        }
    }
    
    var fullPriceDescription: String {
        switch self {
        case .year(let price):
            return "$ \(price)"
        case .month(let price):
            return "$ \(price)"
        }
    }
    
    var badgeText: String? {
        switch self {
        case .year:
            return "SAVE 80%"
        case .month:
            return nil
        }
    }
    
    var isYearly: Bool {
        switch self {
        case .year: return true
        case .month: return false
        }
    }
}

// MARK: - Equatable
extension SubscriptionProduct: Equatable {
    static func == (lhs: SubscriptionProduct, rhs: SubscriptionProduct) -> Bool {
        switch (lhs, rhs) {
        case (.year(let leftPrice), .year(let rightPrice)):
            return leftPrice == rightPrice
        case (.month(let leftPrice), .month(let rightPrice)):
            return leftPrice == rightPrice
        default:
            return false
        }
    }
}
