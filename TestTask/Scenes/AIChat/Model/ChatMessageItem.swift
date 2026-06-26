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

