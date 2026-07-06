//
//  AIChatViewModel.swift
//  TestTask
//
//  Created by Vit Chernuhin on 24.06.2026.
//

import Foundation
import Combine
import XCoordinator

final class AIChatViewModel: Logable {
    
    // MARK: - Outputs (Данные для подписки)
    @Published private(set) var messages: [ChatMessageItem] = []
    @Published private(set) var screenState: ChatScreenState = .emptyInitial
    @Published private(set) var isAISpeaking: Bool = false
    
    // MARK: - Services & Navigation
    private let router: WeakRouter<MainRoute>
    private let chatNetworkService: AIChatNetworkService
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init(router: WeakRouter<MainRoute>, chatNetworkService: AIChatNetworkService) {
        self.router = router
        self.chatNetworkService = chatNetworkService
    }
}

// MARK: - ViewActionHandable (implementation)
extension AIChatViewModel: ViewActionHandlable {
    func handleAction(_ action: AIChatAction) {
        switch action {
        case .inputStateChanged(let hasText):
            executeInputChange(hasText: hasText)
            
        case .sendTapped(let text):
            executeMessageSending(text)
            
        case .historyTapped:
            router.trigger(.aiChatsHistory)
            
        case .backTapped:
            router.trigger(.back)
        }
    }
}

// MARK: - Private methods
private extension AIChatViewModel {
    
    func executeInputChange(hasText: Bool) {
        guard screenState != .hasMessages else { return }
        screenState = hasText ? .typingEmptyChat : .emptyInitial
    }
    
    func executeMessageSending(_ text: String) {
        guard !isAISpeaking else { return }
        
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        let userMessage = ChatMessageItem(text: trimmedText, sender: .user, date: Date())
        messages.append(userMessage)
        
        screenState = .hasMessages
        isAISpeaking = true
    
        let userId = AppConfig.testUserId
        let appId = AppConfig.testApplicationId
        let targetChatId = "\(userId)_\(appId)".deterministicUUIDString

        chatNetworkService.sendPrompt(
            chatId: targetChatId,
            userId: userId,
            text: trimmedText,
            locale: nil
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            guard let self = self else { return }
            self.isAISpeaking = false
            
            if case .failure(let error) = completion {
                log(message: "Ошибка сети: \(error.localizedDescription)")
                self.router.trigger(.alert(type: .error, message: error.localizedDescription))
            }
        } receiveValue: { [weak self] response in
            guard let self = self else { return }
            
            let aiText = response.assistantMessage
            let aiMessage = ChatMessageItem(text: aiText, sender: .ai, date: Date())
            self.messages.append(aiMessage)
        }
        .store(in: &cancellables)
    }
}
