//
//  FontFamaly.swift
//  TestTask
//
//  Created by Vit Chernuhin on 21.06.2026.
//

import UIKit

enum FontFamily {
    enum Inter {
        static func regular(size: CGFloat) -> UIFont {
            return UIFont(name: "Inter-Regular", size: size) ?? .systemFont(ofSize: size)
        }
        
        static func medium(size: CGFloat) -> UIFont {
            return UIFont(name: "Inter-Medium", size: size) ?? .systemFont(ofSize: size, weight: .medium)
        }
        
        static func semiBold(size: CGFloat) -> UIFont {
            return UIFont(name: "Inter-SemiBold", size: size) ?? .systemFont(ofSize: size, weight: .semibold)
        }
        
        static func bold(size: CGFloat) -> UIFont {
            return UIFont(name: "Inter-Bold", size: size) ?? .systemFont(ofSize: size, weight: .bold)
        }
    }
}
