//
//  AIChatModels.swift
//  TestTask
//
//  Created by Vit Chernuhin on 24.06.2026.
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

// MARK: - AIChatResponse
struct AIChatResponse: Decodable {
    let chatId: String
    let assistantMessage: String
    
    enum CodingKeys: String, CodingKey {
        case chatId = "chat_id"
        case assistantMessage = "assistant_message"
    }
}

// MARK: - Network Errors
enum AIChatError: Error {
    /// Ошибка 422 — не прошли регулярные выражения или забыли параметр
    case validation(String)
    /// Ошибка 404 — чат с таким ID не существует на бэкенде
    case chatNotFound
    /// Ошибка 500+ — проблемы на стороне самого сервера
    case serverError
    /// Ошибка сети — нет интернета или таймаут соединения
    case noInternet
    /// Неизвестная ошибка
    case unknown(String)
}

// MARK: - LocalizedError Conformance (English Version)
extension AIChatError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .validation(let reason):
            return reason.isEmpty
                ? "Invalid data format. Please verify your input parameters."
                : "Validation error: \(reason)"
            
        case .chatNotFound:
            return "Active session not found. Please try to restart the chat."
            
        case .serverError:
            return "Server is temporarily unavailable. We are fixing it, please try again later."
            
        case .noInternet:
            return "Connection lost. Please check your internet network and retry."
            
        case .unknown(let details):
            return details.isEmpty
                ? "An unexpected error occurred. Please try again."
                : "Error details: \(details)"
        }
    }
}

// MARK: - Validation Error Models (422)

struct ValidationErrorResponse: Decodable {
    let detail: [ValidationErrorDetail]
}

struct ValidationErrorDetail: Decodable {
    let loc: [DetailLocation]
    let msg: String
    let type: String
    let input: String? // Опционально, так как для missing полей его не будет
    
    enum DetailLocation: Decodable {
        case string(String)
        case number(Int)
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let stringValue = try? container.decode(String.self) {
                self = .string(stringValue)
                return
            }
            if let intValue = try? container.decode(Int.self) {
                self = .number(intValue)
                return
            }
            throw DecodingError.typeMismatch(
                DetailLocation.self,
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Неизвестный тип в loc")
            )
        }
    }
}

