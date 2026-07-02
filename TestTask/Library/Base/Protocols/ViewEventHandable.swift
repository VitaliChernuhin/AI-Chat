//
//  ViewEventHandable.swift
//  TestTask
//
//  Created by Vit Chernuhin on 01.07.2026.
//

/// Протокол для вью-моделей, умеющих обрабатывать системные события жизненного цикла View
protocol ViewEventHandlable: AnyObject {
    associatedtype Event
    
    func handleViewEvent(_ event: Event)
}
