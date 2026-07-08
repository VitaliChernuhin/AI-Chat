//
//  AIChatError.swift
//  TestTask
//
//  Created by Vit Chernuhin on 06.07.2026.
//

import Foundation

// MARK: - Network Errors
enum AIChatError: Error {
    /// Ошибка 422 — не прошли регулярные выражения или забыли параметр
    case validation(AIValidationErrorDetail)
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
        case .validation(let detail):
            return detail.msg.isEmpty
                ? "Invalid data format. Please verify your input parameters."
                : "Validation error: \(detail.msg)"
            
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
