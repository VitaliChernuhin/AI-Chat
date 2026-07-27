//
//  ViewActionHandable.swift
//  TestTask
//
//  Created by Vit Chernuhin on 01.07.2026.
//

/// Протокол для вью-моделей, умеющих обрабатывать действия и тапы пользователя
protocol ViewActionHandlable: AnyObject {
    associatedtype Action
    
    func handleAction(_ action: Action)
}
