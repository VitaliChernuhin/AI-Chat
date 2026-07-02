//
//  ServicesFactory.swift
//  TestTask
//
//  Created by Vit Chernuhin on 20.06.2026.
//

import Foundation
import Swinject

final class ServicesFactory: @unchecked Sendable {
    
    // MARK: - Static Singleton
    // Делаем фабрику статической, чтобы безопасно вызывать сервисы на любом потоке
    static let shared = ServicesFactory()
    
    // MARK: - Private properties
    private let container: Container
    
    // MARK: - Init
    // Делаем инициализатор приватным, чтобы никто случайно не создал вторую копию
    private init() {
        self.container = Container()
        self.registerServices()
    }
    
    // MARK: - Public methods
    func service<T: Any>(type: T.Type) -> T {
        guard let service = container.resolve(T.self) else {
            fatalError("Unregistered service: \(T.self)")
        }
        return service
    }
    
    // MARK: - Private registrations
    private func registerServices() {
        container.register(AIChatNetworkService.self) { _ in
            AIChatNetworkServiceImpl()
        }.inObjectScope(.transient)
        
        container.register(SubscriptionService.self) { _ in
            SubscriptionServiceImpl()
        }.inObjectScope(.container)
    }
}
