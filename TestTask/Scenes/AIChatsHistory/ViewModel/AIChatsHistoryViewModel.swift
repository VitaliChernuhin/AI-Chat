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

// MARK: - Private methods
private extension AIChatsHistoryViewModel {
    func loadHistoryFromBackend() {
        // Моки для верстки
        self.chatSections = [
            "Today": [
                ChatHistoryItem(id: "1", text: "Create a design system for a mobile app in Figma", time: "14:32"),
                ChatHistoryItem(id: "2", text: "Explain quantum computing in simple words for a kid", time: "10:15")
            ],
            "Yesterday": [
                ChatHistoryItem(id: "3", text: "Write a high-performance HTTP server in Python using FastAPI", time: "Yesterday")
            ],
            "March 4": [
                ChatHistoryItem(id: "4", text: "How to fix jumpy UICollectionView layouts on iOS 15?", time: "04.03.2026")
            ]
        ]
        
        // РЕШЕНИЕ: Гасим пустой стейт, чтобы на экране включилась коллекция контента!
        self.isEmpty = false
    }
}

