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
    func configure(with parts: [String], font: UIFont, textColor: UIColor) {
        guard parts.count >= 2 else { return }
        
        // 1. Создаем вложение для нашей дизайнерской точки
        let dotAttachment = NSTextAttachment()
        if let dotImage = AppIcons.MainPage.bulletDot {
            dotAttachment.image = dotImage.withRenderingMode(.alwaysTemplate)
        }
        
        // Сдвигаем точку по вертикали, чтобы она стояла строго по центру букв
        dotAttachment.bounds = CGRect(x: 0, y: 3.5, width: 4, height: 4)
        
        // 2. Собираем атрибутированную строку
        let finalAttributedString = NSMutableAttributedString()
        
        // Общие атрибуты для текста
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: textColor
        ]
        
        // Левая часть
        let leftPart = NSAttributedString(string: parts[0] + "   ", attributes: textAttributes)
        
        // Это заставит системный рендерер принудительно перекрасить .alwaysTemplate картинку в нужный нам textColor
        let dotString = NSMutableAttributedString(attachment: dotAttachment)
        dotString.addAttributes([.foregroundColor: textColor], range: NSRange(location: 0, length: dotString.length))
        
        // Правая часть
        let rightPart = NSAttributedString(string: "   " + parts[1], attributes: textAttributes)
        
        // Соединяем все слои
        finalAttributedString.append(leftPart)
        finalAttributedString.append(dotString) // Добавляем принудительно покрашенную точку
        finalAttributedString.append(rightPart)
        
        // Прокидываем готовую строку в лейбл
        textLabel.attributedText = finalAttributedString
        
        // Управляем прозрачностью всей строки (70% для левой карточки)
        textLabel.alpha = textColor == AppColors.placeholderText ? 1.0 : 0.7
    }

}
