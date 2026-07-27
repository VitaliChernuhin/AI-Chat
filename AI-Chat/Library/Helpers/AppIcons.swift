//
//  AppIcons.swift
//  TestTask
//
//  Created by Vit Chernuhin on 21.06.2026.
//

import UIKit

enum AppIcons {
    
    // MARK: - MainPage
    enum MainPage {
        static let settings = UIImage(named: "settings")
        static let logo = UIImage(named: "logo")
        static let askAny = UIImage(named: "ask_any")
        static let turnPhotoToVideo = UIImage(named: "turn_photo_to_video")
        static let fixWriting = UIImage(named: "fix_writing")
        static let summarize = UIImage(named: "summarize")
        static let bgWaveLine = UIImage(named: "bg_wave_line")
        static let bulletDot = UIImage(named: "ic_bullet_dot")
        static let play = UIImage(named: "play")
        
        static let systemLock: UIImage? = {
            let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
            return UIImage(systemName: "lock.fill", withConfiguration: config)
        }()
    }
    
    // MARK: - Chat
    enum Chat {
        static let arrowDown = UIImage(named: "ic_arrow_down")
        static let paperplane = UIImage(named: "ic_paperplane")
        static let microphone = UIImage(named: "ic_chat_microphone")
    }
    
    // MARK: - NavigationBar
    enum NavigationBar {
        static let back = UIImage(named: "navBar_back")
        static let chatAvatar = UIImage(named: "ic_chat_avatar")
        static let history = UIImage(named: "ic_history")
    }
    
    // MARK: - Alert
    enum Alert {
        
        static let successCheck = UIImage(named: "ic_success_check")
        
        /// Системный знак предупреждения, покрашенный в неоново-розовый цвет бренда! ⚠️
        static let errorWarning: UIImage? = {
            let config = UIImage.SymbolConfiguration(paletteColors: [AppColors.brandGradientEnd])
            return UIImage(systemName: "exclamationmark.triangle.fill", withConfiguration: config)
        }()
    }
    
    // MARK: - Paywall
    enum Paywall {
        static let close = UIImage(named: "ic_close")
        static let resultInSeconds = UIImage(named: "ic_result_in_seconds")
        static let turnAnyText = UIImage(named: "ic_turn_any_text")
        static let simplifyComplexInformation = UIImage(named: "ic_simplify_complex_information")
        static let createWithAITemplate = UIImage(named: "ic_create_with_AI_templates")
        static let cancelAnyTime = UIImage(named: "ic_cancel_anyTime")
    }
    
    // MARK: - Chats history
    enum ChatsHistory {
        static let placeholder = UIImage(named: "ic_chats_history_placeholder")
        static let historyItem = UIImage(named: "ic_chats_history_item")
    }
}
