//
//  AIChatViewModel.swift
//  TestTask
//
//  Created by Vit Chernuhin on 24.06.2026.
//

import Foundation
import Combine
import XCoordinator

final class AIChatViewModel {
    
    // MARK: - Outputs (Данные для подписки из ViewController)
    @Published private(set) var messages: [ChatMessageItem] = []
    @Published private(set) var screenState: ChatScreenState = .emptyInitial
    @Published private(set) var isAISpeaking: Bool = false // Показывает, крутится ли сейчас typing indicator
    
    // MARK: - Services & Navigation
    private let router: WeakRouter<MainRoute>
    private let chatNetworkService: AIChatNetworkService
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init(router: WeakRouter<MainRoute>, chatNetworkService: AIChatNetworkService) {
        self.router = router
        self.chatNetworkService = chatNetworkService
    }
    
    // MARK: - Inputs (Методы, вызываемые из ViewController)
    
    /// Обрабатывает изменение текста в поле ввода, пока чат пустой
    func changeInputState(hasText: Bool) {
        // Если сообщения уже есть, стейт .hasMessages заблокирован навсегда
        guard screenState != .hasMessages else { return }
        screenState = hasText ? .typingEmptyChat : .emptyInitial
    }
    
    /// Отправляет сообщение пользователя к ИИ
    func sendMessage(_ text: String) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        // 1. Добавляем чистое сообщение пользователя в локальную историю
        let userMessage = ChatMessageItem(text: trimmedText, sender: .user, date: Date())
        messages.append(userMessage)
        
        // Переключаем экран в контентный режим (скрываем WelcomeView навсегда)
        screenState = .hasMessages
        
        // 2. Включаем индикатор набора текста для AI (три точки)
        isAISpeaking = true
        
        // 3. Генерируем стабильный UUID чата на основе user + app scope через твое расширение String+UUID
        let userId = AppConfig.testUserId
        let appId = AppConfig.testApplicationId
        let targetChatId = "\(userId)_\(appId)".UUIDString
        
        // 4. Стучимся в сеть к ИИ через Moya/Combine
        chatNetworkService.sendPrompt(
            chatId: targetChatId,
            userId: userId,
            text: trimmedText,
            locale: nil
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            guard let self = self else { return }
            // Выключаем индикатор загрузки при любом исходе запроса
            self.isAISpeaking = false
            
            if case .failure(let error) = completion {
                print("Ошибка сети во ViewModel: \(error.localizedDescription)")
            }
        } receiveValue: { [weak self] response in
            guard let self = self else { return }
            
            let aiText = response.assistantMessage
            let aiMessage = ChatMessageItem(text: aiText, sender: .ai, date: Date())
            
            self.messages.append(aiMessage)
        }
        .store(in: &cancellables)
    }
    
    // MARK: - Navigation Inputs
    func openHistory() {
        // router.trigger(.history)
    }
}
