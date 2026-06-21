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
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        
        var config = UIButton.Configuration.plain()
        config.title = "Ready in seconds"
        config.baseForegroundColor = AppColors.accent
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = FontFamily.Inter.regular(size: 12)
            return outgoing
        }
        
        if let playImage = AppIcons.MainPage.play {
            config.image = playImage.withRenderingMode(.alwaysTemplate)
        }
        config.imagePlacement = .trailing // Иконка строго справа
        config.imagePadding = 8           // Отступ 8pt от текста до стрелочки
        
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        
        var backgroundConfig = UIBackgroundConfiguration.clear()
        backgroundConfig.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        backgroundConfig.cornerRadius = 16
        
        config.background = backgroundConfig
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
            
            subtitleView.configure(with: item.subtitleParts,
                                   font: subtitleFont,
                                   textColor: AppColors.accent.withAlphaComponent(0.7))
            
            subtitleView.snp.remakeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(12) // Отступ 12pt от заголовка
                make.leading.equalTo(titleLabel.snp.leading)
                make.trailing.equalToSuperview().offset(-16)
                make.height.equalTo(18)
            }
        } else {
            // --- ПРАВЫЕ КАРТОЧКИ ---
            backgroundColor = AppColors.card
            gradientLayer.isHidden = true
            waveImageView.isHidden = true
            titleLabel.font = FontFamily.Inter.medium(size: 16)
            
            subtitleView.configure(with: item.subtitleParts,
                                   font: subtitleFont,
                                   textColor: AppColors.placeholderText)
            
            // ДИНАМИЧЕСКИЙ ЛЕЙАУТ: прибиваем строго к НИЖНЕМУ краю с отступом 16pt! 🌟
            subtitleView.snp.remakeConstraints { make in
                make.leading.equalTo(titleLabel.snp.leading)
                make.trailing.equalToSuperview().offset(-8) 
//                make.trailing.equalToSuperview().offset(-16)
                make.bottom.equalToSuperview().offset(-16) // Отступ 16pt от самого низа карточки
                make.height.equalTo(18)
            }
        }
    }

    
    // MARK: - Setup
    private func setupCell() {
        layer.cornerRadius = 24
        clipsToBounds = true
        
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
        
        subtitleView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.equalTo(titleLabel.snp.leading)
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
