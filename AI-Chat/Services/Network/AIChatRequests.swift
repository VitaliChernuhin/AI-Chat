//
//  AIChatRequests.swift
//  TestTask
//
//  Created by Vit Chernuhin on 06.07.2026.
//
import Foundation

// MARK: - AIChatRequest
struct AIChatRequest: Encodable {
    let message: String
    let personaId: String?
    let additionalPrompt: String?
    
    enum CodingKeys: String, CodingKey {
        case message
        case personaId = "persona_id"
        case additionalPrompt = "additional_prompt"
    }
}
