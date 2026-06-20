//
//  ServicesFactory.swift
//  TestTask
//
//  Created by Vit Chernuhin on 20.06.2026.
//

import Foundation
import Swinject

protocol ServicesFactory {
    func service<T: Any>(type: T.Type) -> T
}

final class ServicesFactoryImpl: ServicesFactory {
    
    // MARK: - Private properties
    private let container: Container
    
    // MARK: - Init
    init() {
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
        
    }
}
