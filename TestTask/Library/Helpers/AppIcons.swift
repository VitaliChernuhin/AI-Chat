//
//  AppIcons.swift
//  TestTask
//
//  Created by Vit Chernuhin on 21.06.2026.
//

import UIKit

enum AppIcons {
    
    enum MainPage {
        static var settings: UIImage? {
            return UIImage(named: "settings")
        }
        
        static var logo: UIImage? {
            return UIImage(named: "logo")
        }
        
        static var askAny: UIImage? {
            return UIImage(named: "ask_any")
        }
        
        static var turnPhotoToVideo: UIImage? {
            return UIImage(named: "turn_photo_to_video")
        }
        
        static var fixWriting: UIImage? {
            return UIImage(named: "fix_writing")
        }
        
        static var summarize: UIImage? {
            return UIImage(named: "summarize")
        }
        
        static var bgWaveLine: UIImage? {
            return UIImage(named: "bg_wave_line")
        }
        
        static var bulletDot: UIImage? {
            return UIImage(named: "ic_bullet_dot")
        }
        
        static var play: UIImage? {
            return UIImage(named: "play")
        }
    }
    
    enum NavigationBar {
        static var back: UIImage? {
            return UIImage(named: "navBar_back")
        }
        
        static var chatAvatar: UIImage? {
            return UIImage(named: "ic_chat_avatar")
        }
        
        static var history: UIImage? {
            return UIImage(named: "ic_history")
        }
    }
}
