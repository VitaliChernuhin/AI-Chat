//
//  ProductUIModel.swift
//  TestTask
//
//  Created by Vit Chernuhin on 02.07.2026.
//

struct ProductUIModel: PaywallProductCellRepresentable {
    let type: SubscriptionProduct
    let title: String
    let price: String
    let badge: String?
    var isSelected: Bool
}
