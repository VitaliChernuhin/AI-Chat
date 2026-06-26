//
//  ChatScreenState.swift
//  TestTask
//
//  Created by Vit Chernuhin on 26.06.2026.
//

import Foundation

enum ChatScreenState {
    /// Чистый экран (история пуста, пользователь еще ничего не напечатал)
    case emptyInitial
    /// Начат ввод текста (сообщений еще нет, но в поле появилась хотя бы одна буква)
    case typingEmptyChat
    /// В чате есть контент (появилось хотя бы одно сообщение — экран приветствия скрыт навсегда)
    case hasMessages
}
