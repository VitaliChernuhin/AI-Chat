//
//  FeatureCell.swift
//  TestTask
//
//  Created by Vit Chernuhin on 21.06.2026.
//

import UIKit
import SnapKit

final class FeatureCell: UICollectionViewCell {
    
    // MARK: - UI Components
    private let gradientLayer = CAGradientLayer()
    
    // Векторная волнистая линия фонового рисунка
    private let waveImageView: UIImageView = {
        let imageView = UIImageView()
        if let waveImage = AppIcons.MainPage.bgWaveLine {
            imageView.image = waveImage
        }
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isHidden = true // Скрыта для правых темных карточек
        return imageView
    }()
    
    // Белая круглая подложка под иконку фичи
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        imageView.tintColor = AppColors.accent
        imageView.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        imageView.layer.cornerRadius = 24
        imageView.clipsToBounds = true
        return imageView
    }()
    
    // Заголовок карточки (Medium 20 для левой, Medium 16 для правых)
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppColors.accent
        label.numberOfLines = 2
        
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75 // Шрифт может плавно сжаться на четверть на мелких экранах
        label.lineBreakMode = .byTruncatingTail // Обязательный параметр для работы сжатия строк!
        
        return label
    }()
    
    private let subtitleView = FeatureSubtitleView()
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        
        var config = UIButton.Configuration.plain()
        config.title = "Ready in seconds"
        config.baseForegroundColor = AppColors.accent
        
        // 1. Жестко запрещаем перенос заголовка кнопки на две строки
        config.titleLineBreakMode = .byTruncatingTail
        
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = FontFamily.Inter.regular(size: 12)
            return outgoing
        }
        
        if let playImage = AppIcons.MainPage.play {
            config.image = playImage.withRenderingMode(.alwaysTemplate)
        }
        config.imagePlacement = .trailing
        config.imagePadding = 8
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)
        
        var backgroundConfig = UIBackgroundConfiguration.clear()
        backgroundConfig.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        backgroundConfig.cornerRadius = 16
        
        config.background = backgroundConfig
        button.configuration = config
        
        // 2. Включаем Autoshrink для внутреннего текстового поля кнопки
        if let titleLabel = button.titleLabel {
            titleLabel.adjustsFontSizeToFitWidth = true
            titleLabel.minimumScaleFactor = 0.8
        }
        
        button.isUserInteractionEnabled = false
        button.isHidden = true
        return button
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = contentView.bounds
    }
    
    // MARK: - Configuration
    func configure(with item: FeatureItem) {
        titleLabel.text = item.title
        actionButton.isHidden = !item.hasActionButton
        
        switch item.type {
        case .turnPhotoToVideo:
            iconImageView.image = AppIcons.MainPage.turnPhotoToVideo
        case .fixWriting:
            iconImageView.image = AppIcons.MainPage.fixWriting
        case .summarize:
            iconImageView.image = AppIcons.MainPage.summarize
        }
        
        // 1. Измеряем высоту экрана для адаптивной типографики
        let isSmallScreen = UIDevice.isSmallScreen
        
        let titleFont: UIFont
        let subtitleFont: UIFont
        
        if item.isGradient {
            titleFont = isSmallScreen ? FontFamily.Inter.medium(size: 18) : FontFamily.Inter.medium(size: 20)
            subtitleFont = FontFamily.Inter.regular(size: 14)
        } else {
            titleFont = isSmallScreen ? FontFamily.Inter.medium(size: 14) : FontFamily.Inter.medium(size: 16)
            subtitleFont = isSmallScreen ? FontFamily.Inter.regular(size: 12) : FontFamily.Inter.regular(size: 14)
        }
        
        // Применяем вычисленный шрифт к заголовку ячейки
        titleLabel.font = titleFont
        
        if item.isGradient {
            // --- ЛЕВАЯ КАРТОЧКА ---
            backgroundColor = .clear
            gradientLayer.isHidden = false
            waveImageView.isHidden = false
            
            subtitleView.configure(with: item.subtitleParts,
                                   font: subtitleFont,
                                   textColor: AppColors.accent.withAlphaComponent(0.7),
                                   alignment: .left)
            
            subtitleView.snp.remakeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(12)
                make.leading.equalTo(titleLabel.snp.leading)
                make.trailing.equalToSuperview().offset(-16)
                make.height.equalTo(18)
            }
        } else {
            // --- ПРАВЫЕ КАРТОЧКИ ---
            backgroundColor = AppColors.card
            gradientLayer.isHidden = true
            waveImageView.isHidden = true
            
            subtitleView.configure(with: item.subtitleParts,
                                   font: subtitleFont,
                                   textColor: AppColors.placeholderText,
                                   alignment: .left)
            
            let bottomOffset: CGFloat = isSmallScreen ? -10 : -16
            
            subtitleView.snp.remakeConstraints { make in
                make.leading.equalTo(titleLabel.snp.leading) // Идеальная соосность по левому краю заголовка 🌟
                make.trailing.equalToSuperview().offset(-8)
                make.bottom.equalToSuperview().offset(bottomOffset)
                make.height.equalTo(18)
            }
        }
    }
    
    // MARK: - Setup
    private func setupCell() {
        layer.cornerRadius = 24
        clipsToBounds = true
        
        gradientLayer.colors = [AppColors.brandGradientStart.cgColor, AppColors.brandGradientEnd.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.isHidden = true
        
        // Вставляем градиент на самый задний план слоя contentView.layer
        contentView.layer.insertSublayer(gradientLayer, at: 0)
        
        // Волна ложится вторым слоем, строго поверх градиентной подложки
        contentView.addSubview(waveImageView)
        
        // Элементы интерфейса карточки
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleView)
        contentView.addSubview(actionButton)
    }
    
    private func setupConstraints() {
        waveImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let isSmallScreen = UIDevice.isSmallScreen
        
        // Адаптивные отступы: на SE поднимаем иконку выше (12pt вместо 24pt)
        let topOffset: CGFloat = isSmallScreen ? 12 : 24
        let titleTopOffset: CGFloat = isSmallScreen ? 6 : 12
        
        iconImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(topOffset) // Адаптивный верхний отступ
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(48)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(titleTopOffset) // Плотный зазор на SE
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        // Базовые горизонтальные ограничения для подзаголовка
        subtitleView.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.leading)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(18)
        }
        
        actionButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-16)
            make.height.equalTo(32)
        }
    }
}
