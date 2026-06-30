//
//  ChatAPI.swift
//  TestTask
//
//  Created by Vit Chernuhin on 24.06.2026.
//


import Foundation
import Moya
internal import Alamofire

enum ChatAPI {
    /// Отправка сообщения со всеми обязательными Query, Path, Body параметрами и локализацией в Header
    case sendMessage(
        chatId: String,
        userId: String,
        appId: String,
        locale: String?,
        acceptLanguage: String?,
        request: AIChatRequest
    )
}

extension ChatAPI: TargetType {
    
    var baseURL: URL {
        // Базовый домен
        return URL(string: "https://nebulaapps.site")!
    }
    
    var path: String {
        switch self {
        case .sendMessage(let chatId,_,_,_,_,_):
            return "/dola/chats/\(chatId)/messages"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .sendMessage:
            return .post
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .sendMessage(_, let userId, let appId, let locale, _, let request):
            
            var urlParameters: [String: Any] = [
                "user_id": userId,
                "app_id": appId
            ]
            
            if let locale = locale {
                urlParameters["locale"] = locale
            }
            
            guard let bodyData = try? JSONEncoder().encode(request),
                  let bodyParameters = try? JSONSerialization.jsonObject(with: bodyData) as? [String: Any] else {
                return .requestPlain
            }
            
            return .requestCompositeParameters(
                bodyParameters: bodyParameters,
                bodyEncoding: JSONEncoding.default,
                urlParameters: urlParameters
            )
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .sendMessage(_, _, _, _, let acceptLanguage, _):
            var headers = [
                "Content-Type": "application/json",
                "Accept": "application/json",
                "Authorization": "Bearer \(AppConfig.testBearerToken)"
            ]
            headers["Accept-Language"] = acceptLanguage ?? "en"
            return headers
        }
    }
    
    var sampleData: Data {
        return Data()
    }
}
