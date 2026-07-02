//
//  SubscriptionService.swift
//  TestTask
//
//  Created by Vit Chernuhin on 02.07.2026.
//

import Foundation
import Combine

protocol SubscriptionService: AnyObject {
    
    /// Массив доступных продуктов (тарифов), загруженных из Apphud
    var products: AnyPublisher<[SubscriptionProduct], Never> { get }
    
    /// Состояние процесса покупки (загрузка / блокировка UI)
    var isPurchasing: AnyPublisher<Bool, Never> { get }
    
    /// Загрузить доступные подписки из сети
    func loadProducts()
    
    /// Запустить процесс покупки конкретного тарифа
    func purchase(_ product: SubscriptionProduct) async throws -> Bool
    
    /// Восстановить прошлые покупки пользователя
    func restorePurchases() async throws -> Bool
}

final class SubscriptionServiceImpl: SubscriptionService {
    
    // MARK: - Reactive Properties
    private let productsSubject = CurrentValueSubject<[SubscriptionProduct], Never>([.year, .month])
    private let isPurchasingSubject = CurrentValueSubject<Bool, Never>(false)
    
    var products: AnyPublisher<[SubscriptionProduct], Never> {
        productsSubject.eraseToAnyPublisher()
    }
    
    var isPurchasing: AnyPublisher<Bool, Never> {
        isPurchasingSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Public Methods
    func loadProducts() {
        print("SubscriptionServiceImpl: Запрос доступных продуктов из Apphud...")
    }
    
    func purchase(_ product: SubscriptionProduct) async throws -> Bool {
        isPurchasingSubject.send(true)
        print("SubscriptionServiceImpl: Попытка покупки через Apphud тарифа: \(product)")
        
        try await Task.sleep(nanoseconds: 1_500_000_000)
        
        isPurchasingSubject.send(false)
        return true
    }
    
    func restorePurchases() async throws -> Bool {
        isPurchasingSubject.send(true)
        print("SubscriptionServiceImpl: Запрос на восстановление покупок в Apphud...")
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        isPurchasingSubject.send(false)
        return true
    }
}
