//
//  AIChatNetworkService.swift
//  TestTask
//
//  Created by Vit Chernuhin on 24.06.2026.
//

import Foundation
import Combine
import Moya
import CombineMoya

// MARK: - Protocol
protocol AIChatNetworkService {
    /// Отправляет текстовый запрос к ИИ в конкретный чат
    /// - Parameters:
    ///   - chatId: Идентификатор чата в Dola (Path-параметр)
    ///   - userId: ID пользователя (Query-параметр с валидацией регулярки)
    ///   - text: Текст сообщения от пользователя (Body-параметр "message")
    ///   - locale: Язык ответа (Query-параметр, опциональный)
    func sendPrompt(chatId: String, userId: String, text: String, locale: String?) -> AnyPublisher<AIChatResponse, Error>
}

// MARK: - Implementation
final class AIChatNetworkServiceImpl: AIChatNetworkService {
    
    private let provider = MoyaProvider<ChatAPI>()
    
    init() {}
    
    func sendPrompt(chatId: String, userId: String, text: String, locale: String? = nil) -> AnyPublisher<AIChatResponse, Error> {
        let appId = AppConfig.testApplicationId
        let systemLanguage = Locale.current.language.languageCode?.identifier
        
        let requestBody = AIChatRequest(
            message: text,
            personaId: nil,
            additionalPrompt: nil
        )
        
        let decoder = JSONDecoder()
        
        return provider.requestPublisher(
            .sendMessage(
                chatId: chatId,
                userId: userId,
                appId: appId,
                locale: locale,
                acceptLanguage: systemLanguage,
                request: requestBody
            )
        )
        .tryMap { response -> Data in
            switch response.statusCode {
            case 200...299:
                return response.data
                
            case 404:
                throw AIChatError.chatNotFound
                
            case 422:
                if let errorResponse = try? decoder.decode(ValidationErrorResponse.self, from: response.data),
                   let firstDetail = errorResponse.detail.first {
                    throw AIChatError.validation(firstDetail.msg)
                }
                throw AIChatError.validation("Validation Error")
                
            case 500...599:
                throw AIChatError.serverError
                
            default:
                throw AIChatError.unknown("HTTP Code: \(response.statusCode)")
            }
        }
        .decode(type: AIChatResponse.self, decoder: decoder)
        .mapError { error -> Error in
            if let chatError = error as? AIChatError { return chatError }
            if let moyaError = error as? MoyaError,
               case let .underlying(underlyingError, _) = moyaError,
               let urlError = underlyingError as? URLError {
                
                switch urlError.code {
                case .notConnectedToInternet, .networkConnectionLost:
                    return AIChatError.noInternet // Реально нет связи
                    
                case .timedOut:
                    return AIChatError.serverError // Сервер слишком долго думал (таймаут)
                    
                default:
                    return AIChatError.unknown("Системный сбой: \(urlError.localizedDescription)")
                }
            }
            return AIChatError.unknown(error.localizedDescription)
        }
        .eraseToAnyPublisher()
    }
}
