//
//  AIChatsHistoryViewModel.swift
//  TestTask
//
//  Created by Vit Chernuhin on 06.07.2026.
//

import Foundation
import Combine
import XCoordinator

final class AIChatsHistoryViewModel: Logable {
    
    // Временная структура для верстки ячейки истории диалога
    struct ChatHistoryItem {
        let id: String
        let text: String
        let time: String
    }
    
    // MARK: - Outputs (Данные для подписки)
    @Published private(set) var chatSections: [String: [ChatHistoryItem]] = [:]
    @Published private(set) var isEmpty: Bool = true
    
    // MARK: - Services & Navigation
    private let router: WeakRouter<MainRoute>
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init(router: WeakRouter<MainRoute>) {
        self.router = router
    }
}

// MARK: - ViewEventHandable (implementation)
extension AIChatsHistoryViewModel: ViewEventHandlable {
    func handleViewEvent(_ event: ViewEvent) {
        switch event {
        case .viewDidLoad:
            loadHistoryFromBackend()
        }
    }
}

// MARK: - ViewActionHandable (implementation)
extension AIChatsHistoryViewModel: ViewActionHandlable {
    func handleAction(_ action: AIChatsHistoryAction) {
        switch action {
        case .backTapped:
            router.trigger(.back)
            
        case .chatSelected(let chatId):
            log(message: "Выбран чат с ID: \(chatId)")
            // В будущем: router.trigger(.aiChat(chatId: chatId))
        }
    }
}

// MARK: - Private Core Logic
private extension AIChatsHistoryViewModel {
    func loadHistoryFromBackend() {
        // Здесь будет твой вчерашний идеальный запрос к FastAPI:
        // 1. Включаем лоадер или проверяем кэш
        // 2. Стягиваем список чатов Dola
        // 3. Если массив пустой -> isEmpty = true
        // 4. Если чаты есть -> парсим, группируем по датам (Today, Yesterday) и гасим isEmpty = false
        
        // Временная заглушка для теста плейсхолдера:
        self.isEmpty = true
    }
}
