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
        return label
    }()
    
    private let subtitleView = FeatureSubtitleView()
    
    // Капсульная кнопка плеера "Ready in seconds"
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        button.layer.cornerRadius = 14
        
        var config = UIButton.Configuration.plain()
        config.title = "Ready in seconds"
        config.baseForegroundColor = AppColors.accent
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = FontFamily.Inter.medium(size: 12)
            return outgoing
        }
        
        if let playImage = UIImage(systemName: "play.fill") {
            config.image = playImage.withRenderingMode(.alwaysTemplate)
        }
        config.imagePlacement = .trailing
        config.imagePadding = 6
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)
        
        button.configuration = config
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
        
        let subtitleFont = FontFamily.Inter.regular(size: 14)
        
        if item.isGradient {
            // --- ЛЕВАЯ КАРТОЧКА ---
            backgroundColor = .clear
            gradientLayer.isHidden = false
            waveImageView.isHidden = false
            titleLabel.font = FontFamily.Inter.medium(size: 20)
            
            // ОБНОВИЛИ: Чистый белый с прозрачностью 70% по замеру 🌟
            subtitleView.configure(with: item.subtitleParts,
                                   font: subtitleFont,
                                   textColor: AppColors.accent.withAlphaComponent(0.7))
        } else {
            // --- ПРАВЫЕ КАРТОЧКИ ---
            backgroundColor = AppColors.card
            gradientLayer.isHidden = true
            waveImageView.isHidden = true
            titleLabel.font = FontFamily.Inter.medium(size: 16)
            
            subtitleView.configure(with: item.subtitleParts,
                                   font: subtitleFont,
                                   textColor: AppColors.placeholderText)
        }

    }
    
    // MARK: - Setup
    private func setupCell() {
        layer.cornerRadius = 24
        clipsToBounds = true
        
        // Настройка оригинальной палитры градиента сверху вниз из Figma
        gradientLayer.colors = [
            UIColor(red: 0.44, green: 0.53, blue: 0.71, alpha: 1.0).cgColor,
            UIColor(red: 0.77, green: 0.35, blue: 0.52, alpha: 1.0).cgColor
        ]
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
        // Фоновая картинка волны растянута на весь экран карточки
        waveImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // Подложка иконки 48х48 с верхним отступом 24pt
        iconImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(48)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        // Позиционируем наш новый кастомный StackView подзаголовка
        subtitleView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.equalTo(titleLabel.snp.leading)
//            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(18) // Высота одной строки
        }
        
        // Кнопка плеера жестко закреплена внизу ячейки
        actionButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(11.5)
            make.trailing.equalToSuperview().offset(-11.5)
            make.bottom.equalToSuperview().offset(-16)
            make.height.equalTo(32)
        }
    }
}
