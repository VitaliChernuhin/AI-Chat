//
//  UIDevice+Extensions.swift
//  TestTask
//
//  Created by Vit Chernuhin on 02.07.2026.
//

import UIKit

extension UIDevice {
    /// Возвращает true, если у текущего устройства маленький экран (iPhone SE 1-3 поколений, iPhone 7, 8)
    static var isSmallScreen: Bool {
        return UIScreen.main.bounds.height <= 667
    }
    
    static var isRunningOnSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
}
