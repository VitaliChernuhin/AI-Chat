//
//  FeatureSubtitleView.swift
//  TestTask
//
//  Created by Vit Chernuhin on 21.06.2026.
//

import UIKit
import SnapKit

final class FeatureSubtitleView: UIView {
    
    // MARK: - UI Components
    private let textLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center // Центрируем строку по умолчанию
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7 // Равномерно ужимаем всю строку на мелких экранах (iPhone SE)
        return label
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupView() {
        addSubview(textLabel)
        textLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: - Configuration
    // Добавили параметр alignment с дефолтным значением .center 🌟
    func configure(with parts: [String], font: UIFont, textColor: UIColor, alignment: NSTextAlignment = .center) {
        guard parts.count >= 2 else { return }
        
        // Меняем выравнивание лейбла на лету!
        textLabel.textAlignment = alignment
        
        let dotAttachment = NSTextAttachment()
        if let dotImage = AppIcons.MainPage.bulletDot {
            dotAttachment.image = dotImage.withRenderingMode(.alwaysTemplate)
        }
        
        dotAttachment.bounds = CGRect(x: 0, y: 3.5, width: 4, height: 4)
        
        let finalAttributedString = NSMutableAttributedString()
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: textColor
        ]
        
        let leftPart = NSAttributedString(string: parts[0] + "   ", attributes: textAttributes)
        
        let dotString = NSMutableAttributedString(attachment: dotAttachment)
        dotString.addAttributes([.foregroundColor: textColor], range: NSRange(location: 0, length: dotString.length))
        
        let rightPart = NSAttributedString(string: "   " + parts[1], attributes: textAttributes)
        
        finalAttributedString.append(leftPart)
        finalAttributedString.append(dotString)
        finalAttributedString.append(rightPart)
        
        textLabel.attributedText = finalAttributedString
        textLabel.alpha = textColor == AppColors.placeholderText ? 1.0 : 0.7
    }
}
