//
//  String+UUID.swift
//  TestTask
//
//  Created by Vit Chernuhin on 24.06.2026.
//

import Foundation
import CryptoKit

extension String {
    /// Генерирует UUID на основе текста методом MD5 хэширования
    var UUIDString: String {
        let inputData = Data(self.utf8)
        let hashed = Insecure.MD5.hash(data: inputData)
        
        // Превращаем хэш в массив байтов (16 байт)
        let bytes = Array(hashed)
        guard bytes.count == 16 else { return UUID().uuidString }
        
        // Форматируем байты строго по стандарту UUID: XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
        return String(
            format: "%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x",
            bytes[0], bytes[1], bytes[2], bytes[3],
            bytes[4], bytes[5],
            bytes[6], bytes[7],
            bytes[8], bytes[9],
            bytes[10], bytes[11], bytes[12], bytes[13], bytes[14], bytes[15]
        )
    }
}
