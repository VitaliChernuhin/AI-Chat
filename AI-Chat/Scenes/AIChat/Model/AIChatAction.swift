//
//  AIChatAction.swift
//  TestTask
//
//  Created by Vit Chernuhin on 06.07.2026.
//

import Foundation

// MARK: - AI Chat Actions
enum AIChatAction {
    case inputStateChanged(hasText: Bool) // Изменение текста, пока чат пустой
    case sendTapped(text: String)
    case historyTapped
    case backTapped
}
