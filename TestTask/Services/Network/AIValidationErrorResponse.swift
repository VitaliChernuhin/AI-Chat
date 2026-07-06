//
//  AIValidationErrorResponse.swift
//  TestTask
//
//  Created by Vit Chernuhin on 06.07.2026.
//
import Foundation

// MARK: - Validation Error Models (422)

struct AIValidationErrorResponse: Decodable {
    let detail: [AIValidationErrorDetail]
}

struct AIValidationErrorDetail: Decodable {
    let loc: [DetailLocation]
    let msg: String
    let type: String
    let input: String? // Опционально, так как для missing полей его не будет
    
    enum DetailLocation: Decodable {
        case string(String)
        case number(Int)
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let stringValue = try? container.decode(String.self) {
                self = .string(stringValue)
                return
            }
            if let intValue = try? container.decode(Int.self) {
                self = .number(intValue)
                return
            }
            throw DecodingError.typeMismatch(
                DetailLocation.self,
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Неизвестный тип в loc")
            )
        }
    }
}
