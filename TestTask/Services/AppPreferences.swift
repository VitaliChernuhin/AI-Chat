//
//  AppPreferences.swift
//  TestTask
//
//  Created by Vit Chernuhin on 05.07.2026.
//


import Foundation

protocol AppPreferences: AnyObject {
    var isPremiumActive: Bool { get set }
}

final class AppPreferencesImpl: AppPreferences {
    
    private let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    var isPremiumActive: Bool {
        get {
            userDefaults.bool(forKey: AppConfig.isPremiumCachedKey)
        }
        set {
            userDefaults.set(newValue, forKey: AppConfig.isPremiumCachedKey)
        }
    }
}
