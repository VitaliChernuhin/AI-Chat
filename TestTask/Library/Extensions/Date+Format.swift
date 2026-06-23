//
//  Date+Format.swift
//  TestTask
//
//  Created by Vit Chernuhin on 23.06.2026.
//

import Foundation

extension Date {
    /// Возвращает дату в формате строки "дд.мм.гггг" (например: 26.03.2026)
    var dotFormattedString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: self)
    }
}
