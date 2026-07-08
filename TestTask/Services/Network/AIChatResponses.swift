
//
//  AIChatResponses.swift
//  TestTask
//
//  Created by Vit Chernuhin on 06.07.2026.
//


import Foundation

// MARK: - AIChatResponse
struct AIChatResponse: Decodable {
    let chatId: String
    let assistantMessage: String
    
    enum CodingKeys: String, CodingKey {
        case chatId = "chat_id"
        case assistantMessage = "assistant_message"
    }
}

// MARK: - AIChatHistoryResponse
struct AIChatHistoryResponse: Codable {
    let chatId: String
    let title: String?
    let personaId: Int?
    let updatedAt: String?
    let lastMessagePreview: String?
    
    enum CodingKeys: String, CodingKey {
        case chatId = "chat_id"
        case title
        case personaId = "persona_id"
        case updatedAt = "updated_at"
        case lastMessagePreview = "last_message_preview"
    }
}

// MARK: - AIChatHistoryMessageResponse
struct AIChatHistoryMessageResponse: Codable {
    let role: String
    let content: String
    let messageSource: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case role
        case content
        case messageSource = "message_source"
        case createdAt = "created_at"
    }
}

