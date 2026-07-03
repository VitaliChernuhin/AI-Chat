//
//  ProductUIModel.swift
//  TestTask
//
//  Created by Vit Chernuhin on 02.07.2026.
//

struct ProductUIModel: PaywallProductCellRepresentable {
    let product: SubscriptionProduct
    let badge: String?
    var isSelected: Bool
    
    init(product: SubscriptionProduct, isSelected: Bool, badge: String? = nil) {
        self.product = product
        self.isSelected = isSelected
        self.badge = badge
    }
    
    var title: String {
        product.title
    }
    
    var price: String {
        product.fullPriceDescription
    }
}
