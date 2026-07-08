//
//  ChatMessageItem.swift
//  TestTask
//
//  Created by Vit Chernuhin on 24.06.2026.
//

import Foundation

enum ChatMessageSender {
    case user
    case ai
}

struct ChatMessageItem {
    let id: UUID = UUID()
    let text: String
    let sender: ChatMessageSender
    let date: Date
}

// MARK: - API Mapping Extension
extension ChatMessageItem {
    init(from response: AIChatHistoryMessageResponse) {
        self.text = response.content
        
        // Мапим строго по доке: "user" или "assistant"
        if response.role == "user" {
            self.sender = .user
        } else {
            self.sender = .ai
        }
        
        // Обрабатываем строку date-time (ISO8601)
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds] // На случай миллисекунд от FastAPI
        self.date = formatter.date(from: response.createdAt) ?? Date()
    }
}

