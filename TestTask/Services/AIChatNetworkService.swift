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
    ///   - appId: ID приложения (Query-параметр)
    ///   - text: Текст сообщения от пользователя (Body-параметр "message")
    ///   - locale: Язык ответа (Query-параметр, опциональный)
    ///   - acceptLanguage: Язык локализации для заголовка (Header-параметр, опциональный)
    func sendPrompt(
        chatId: String,
        userId: String,
        appId: String,
        text: String,
        locale: String?,
        acceptLanguage: String?
    ) -> AnyPublisher<AIChatResponse, Error>
    
    /// Получение всех доступных чатов пользователя
    /// - Parameters:
    ///   - userId: ID пользователя (Query-параметр с валидацией регулярки)
    ///   - appId: ID приложения (Query-параметр)
    ///   - chatsLimitCount: Максимальное количество чатов (limit)
    ///   - chatsPaginationOffset: Смещение для пагинации (offset)
    func chatsList(
        userId: String,
        appId: String,
        chatsLimitCount: Int?,
        chatsPaginationOffset: Int?
    ) -> AnyPublisher<[AIChatHistoryResponse], Error>
}


// MARK: - Implementation
final class AIChatNetworkServiceImpl: AIChatNetworkService {
    
    private let provider = MoyaProvider<ChatAPI>()
    private let decoder = JSONDecoder()
    
    init() {}
    
    /// Отправляет текстовый запрос к ИИ в конкретный чат
    func sendPrompt(
        chatId: String,
        userId: String,
        appId: String,
        text: String,
        locale: String?,
        acceptLanguage: String?
    ) -> AnyPublisher<AIChatResponse, Error> {
        
        let systemLanguage = acceptLanguage ?? Locale.current.language.languageCode?.identifier
        
        let requestBody = AIChatRequest(
            message: text,
            personaId: nil,
            additionalPrompt: nil
        )
        
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
        
        .tryMap { [weak self] response -> Data in
            guard let self = self else { throw AIChatError.unknown("Deallocated context") }
            return try self.handleResponseData(response)
        }
        .decode(type: AIChatResponse.self, decoder: decoder)
        .mapError { [weak self] error -> Error in
            return self?.mapNetworkError(error) ?? AIChatError.unknown(error.localizedDescription)
        }
        .eraseToAnyPublisher()
    }
    
    /// Получение всех доступных чатов пользователя с поддержкой пагинации
    func chatsList(
        userId: String,
        appId: String,
        chatsLimitCount: Int?,
        chatsPaginationOffset: Int?
    ) -> AnyPublisher<[AIChatHistoryResponse], Error> {
        
        return provider.requestPublisher(
            .chatsList(
                userId: userId,
                appId: appId,
                limitChatsCount: chatsLimitCount,
                chatsPaginationOffset: chatsPaginationOffset
            )
        )
        .tryMap { [weak self] response -> Data in
            guard let self = self else { throw AIChatError.unknown("Deallocated context") }
            return try self.handleResponseData(response)
        }
        .decode(type: [AIChatHistoryResponse].self, decoder: decoder) // Декодируем массив плашек истории
        .mapError { [weak self] error -> Error in
            return self?.mapNetworkError(error) ?? AIChatError.unknown(error.localizedDescription)
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Private Network Handlers (Переиспользуемая магия декомпозиции)
private extension AIChatNetworkServiceImpl {
    
    /// Централизованный разбор HTTP-статус кодов для FastAPI
    func handleResponseData(_ response: Response) throws -> Data {
        switch response.statusCode {
        case 200...299:
            return response.data
            
        case 404:
            throw AIChatError.chatNotFound
            
        case 422:
            if let errorResponse = try? decoder.decode(AIValidationErrorResponse.self, from: response.data),
               let firstDetail = errorResponse.detail.first {
                throw AIChatError.validation(firstDetail.msg)
            }
            throw AIChatError.validation("Validation Error")
            
        case 500...599:
            throw AIChatError.serverError
            
        default:
            throw AIChatError.unknown("HTTP Error Code: \(response.statusCode)")
        }
    }
    
    
    /// Централизованный маппинг ошибок Alamofire/Moya в доменные ошибки приложения
    func mapNetworkError(_ error: Error) -> Error {
        if let chatError = error as? AIChatError { return chatError }
        
        if let moyaError = error as? MoyaError,
           case let .underlying(underlyingError, _) = moyaError,
           let urlError = underlyingError as? URLError {
            
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                return AIChatError.noInternet
                
            case .timedOut:
                return AIChatError.serverError
                
            default:
                return AIChatError.unknown("Системный сбой: \(urlError.localizedDescription)")
            }
        }
        return AIChatError.unknown(error.localizedDescription)
    }
}
