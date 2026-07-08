//
//  DynamicValue.swift
//  TestTask
//
//  Created by Vit Chernuhin on 08.07.2026.
//
import Foundation

/// Полностью динамический тип для парсинга любых JSON-структур (any / object) из FastAPI
enum DynamicValue: Decodable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case array([DynamicValue])
    case dictionary([String: DynamicValue])
    case null

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            self = .null
        } else if let intValue = try? container.decode(Int.self) {
            self = .int(intValue)
        } else if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
        } else if let doubleValue = try? container.decode(Double.self) {
            self = .double(doubleValue)
        } else if let boolValue = try? container.decode(Bool.self) {
            self = .bool(boolValue)
        } else if let arrayValue = try? container.decode([DynamicValue].self) {
            self = .array(arrayValue)
        } else if let dictValue = try? container.decode([String: DynamicValue].self) {
            self = .dictionary(dictValue)
        } else {
            throw DecodingError.typeMismatch(
                DynamicValue.self,
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Неподдерживаемая структура JSON")
            )
        }
    }
}

