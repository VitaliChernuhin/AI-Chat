//
//  UIView+Reusable.swift
//  TestTask
//
//  Created by Vit Chernuhin on 21.06.2026.
//

import UIKit

protocol ReusableView: AnyObject {
    static var reuseIdentifier: String { get }
}

extension ReusableView where Self: UIView {
    // Автоматически берет имя самого класса в качестве идентификатора переиспользования
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UICollectionReusableView: ReusableView {}

