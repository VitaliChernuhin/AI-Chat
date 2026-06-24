//
//  AppColors.swift
//  TestTask
//
//  Created by Vit Chernuhin on 20.06.2026.
//

import UIKit

enum AppColors {
    // MARK: - Основные цвета темы (10, 7, 14)
    static let background = UIColor(red: 10/255, green: 7/255, blue: 14/255, alpha: 1.0)
    static let accent = UIColor.white // Или ваш яркий цвет для текста
    
    // MARK: - Навигационная панель
    static let navBarBackground = UIColor(red: 18/255, green: 14/255, blue: 21/255, alpha: 1.0)
    static let navBarSubtitle = UIColor(red: 141/255, green: 139/255, blue: 143/255, alpha: 1.0) // Мягкий серый
    
    // MARK: - Главная страница (MainPage)
    static let card = UIColor(red: 22/255, green: 17/255, blue: 28/255, alpha: 1.0)
    static let settingsIcon = UIColor.white
    static let placeholderText = UIColor(red: 89/255, green: 86/255, blue: 91/255, alpha: 1.0)
    
    // Поле ввода на Главной
    static let askAnyBackground = UIColor(red: 26/255, green: 21/255, blue: 32/255, alpha: 1.0) //
    
    /// Новый цвет нижней панели ввода из дизайна чата (30, 25, 31)
    static let chatAskAnythingBackground = UIColor(red: 30/255, green: 25/255, blue: 31/255, alpha: 1.0)
    
    static let chatInputBorder = UIColor(red: 52/255, green: 48/255, blue: 53/255, alpha: 1.0)
    
    static let chatInputPlaceholderText = UIColor(hex: "#606060")
    
    // MARK: - AIChat
    static let welcomeSubtitle = UIColor(red: 133/255, green: 131/255, blue: 134/255, alpha: 1.0)
}
