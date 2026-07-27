//
//  Logable.swift
//  TestTask
//
//  Created by Vit Chernuhin on 03.07.2026.
//

import Foundation

protocol Logable {
    func log(message: String)
}

extension Logable {
    func log(message: String) {
        let className = String(describing: type(of: self))
        print("➡️ [\(className)]: \(message)")
    }
}
