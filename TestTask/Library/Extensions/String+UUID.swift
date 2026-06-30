//
//  String+UUID.swift
//  TestTask
//
//  Created by Vit Chernuhin on 24.06.2026.
//

import Foundation
import CryptoKit

// MARK: - Deterministic UUID Generator
extension String {
    
    /// Генерирует стабильный, честный UUID на основе содержимого строки (scope)
    var deterministicUUIDString: String {
        let sourceData = Data(self.utf8)
        var bytes = [UInt8](repeating: 0, count: 16)
        
        sourceData.withUnsafeBytes { dataBytes in
            guard let baseAddress = dataBytes.baseAddress else { return }
            let count = min(dataBytes.count, 16)
            memcpy(&bytes, baseAddress, count)
        }
        
        // Выставляем обязательные биты для валидного формата UUID v5
        bytes[6] = (bytes[6] & 0x0F) | 0x50
        bytes[8] = (bytes[8] & 0x3F) | 0x80
        
        let uuid = UUID(uuid: (
            bytes[0], bytes[1], bytes[2], bytes[3], bytes[4], bytes[5], bytes[6], bytes[7],
            bytes[8], bytes[9], bytes[10], bytes[11], bytes[12], bytes[13], bytes[14], bytes[15]
        ))
        
        return uuid.uuidString.lowercased()
    }
}
