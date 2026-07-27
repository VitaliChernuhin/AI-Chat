//
//  ChatLaunchContext.swift
//  TestTask
//
//  Created by Vit Chernuhin on 07.07.2026.
//
import Foundation

enum ChatLaunchContext {
    case newChat
    case history(chatId: String, lastActivityDate: Date)
}
