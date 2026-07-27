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
    @Published private(set) var isLoading: Bool = false // Лоадер для UX
    
    // MARK: - Services & Navigation
    private let router: WeakRouter<MainRoute>
    private let chatNetworkService: AIChatNetworkService
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init(
        router: WeakRouter<MainRoute>,
        chatNetworkService: AIChatNetworkService
    ) {
        self.router = router
        self.chatNetworkService = chatNetworkService
    }
}

// MARK: - ViewEventHandable (implementation)
extension AIChatsHistoryViewModel: ViewEventHandlable {
    func handleViewEvent(_ event: ViewEvent) {
        switch event {
        case .viewDidLoad:
            break
        case .viewWillAppear:
            loadHistory()
        }
    }
}

// MARK: - ViewActionHandable (implementation)
extension AIChatsHistoryViewModel: ViewActionHandlable {
    func handleAction(_ action: AIChatsHistoryAction) {
        switch action {
        case .backTapped:
            router.trigger(.back)
            
        case .chatSelected(let item):
            log(message: "Selected chat with ID: \(item.id)")
            // Прокидываем чистую дату изменения 🎯
            router.trigger(.aiChat(launchContext: .history(chatId: item.id, lastActivityDate: item.date)))
            
        }
    }
}

// MARK: - Private methods
private extension AIChatsHistoryViewModel {
    
    func loadHistory() {
        guard !isLoading else { return }
        
        isLoading = true
        let userId = AppConfig.testUserId
        let appId = AppConfig.testApplicationId
        
        chatNetworkService.chatsList(
            userId: userId,
            appId: appId,
            chatsLimitCount: 50,
            chatsPaginationOffset: 0
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            guard let self = self else { return }
            self.isLoading = false
            
            if case .failure(let error) = completion {
                self.log(
                    message: "Network history failure: \(error.localizedDescription)"
                )
                self.router
                    .trigger(
                        .alert(
                            type: .error,
                            message: error.localizedDescription
                        )
                    )
            }
        } receiveValue: { [weak self] responseArray in
            guard let self = self else { return }
            
            if responseArray.isEmpty {
                self.chatSections = [:]
                self.isEmpty = true
            } else {
                self.chatSections = self.groupHistoryItems(responseArray)
                self.isEmpty = false
            }
        }
        .store(in: &cancellables)
    }
    
    /// Группирует плоский массив ответов сервера в структурированные секции дат
    func groupHistoryItems(_ responses: [AIChatHistoryResponse]) -> [String: [ChatHistoryItem]] {
        var grouped: [String: [ChatHistoryItem]] = [:]
        
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        
        let sectionFormatter = DateFormatter()
        sectionFormatter.dateFormat = "MMMM d"
        sectionFormatter.locale = Locale(identifier: "en_US")
        
        let calendar = Calendar.current
        
        for response in responses {
            let rawDateString = response.updatedAt ?? ""
            let date = isoFormatter.date(from: rawDateString) ?? Date()
            
            let sectionTitle: String
            if calendar.isDateInToday(date) {
                sectionTitle = "Today"
            } else if calendar.isDateInYesterday(date) {
                sectionTitle = "Yesterday"
            } else {
                sectionTitle = sectionFormatter.string(from: date)
            }
            
            let displayTime = calendar.isDateInToday(date)
            ? timeFormatter.string(from: date)
            : (calendar.isDateInYesterday(date) ? "Yesterday" : sectionTitle)
            
            let chatTitle = response.title ?? "New Chat"
            let previewText = response.lastMessagePreview ?? ""
            
            let finalCellText = previewText.isEmpty ? chatTitle : previewText
            
            let item = ChatHistoryItem(
                id: response.chatId,
                text: finalCellText,
                time: displayTime,
                date: date
            )
            
            grouped[sectionTitle, default: []].append(item)
        }
        
        for (key, items) in grouped {
            grouped[key] = items.sorted { $0.date > $1.date }
        }
        
        return grouped
    }
}
