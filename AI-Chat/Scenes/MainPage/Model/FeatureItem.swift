//
//  FeatureItem.swift
//  TestTask
//
//  Created by Vit Chernuhin on 21.06.2026.
//

import Foundation

struct FeatureItem {
    let id = UUID()
    let type: FeatureType
    
    var title: String {
        switch type {
        case .turnPhotoToVideo:
            return "Turn Photo\ninto Video"
        case .fixWriting:
            return "Fix & Improve\nWriting"
        case .summarize:
            return "Understand\nFaster"
        }
    }
    
    var subtitleParts: [String] {
        switch type {
        case .turnPhotoToVideo:
            return ["Animate", "Templates"]
        case .fixWriting:
            return ["Rewrite", "Fix grammar"]
        case .summarize:
            return ["Summarize", "Key points"]
        }
    }
    
    var isGradient: Bool {
        switch type {
        case .turnPhotoToVideo:
            return true
        case .fixWriting, .summarize:
            return false
        }
    }
    
    var hasActionButton: Bool {
        switch type {
        case .turnPhotoToVideo:
            return true
        case .fixWriting, .summarize:
            return false
        }
    }
    
    init(type: FeatureType) {
        self.type = type
    }
}
