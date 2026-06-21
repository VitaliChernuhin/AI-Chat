//
//  FeatureCell.swift
//  TestTask
//
//  Created by Vit Chernuhin on 21.06.2026.
//

import UIKit
import SnapKit

final class FeatureCell: UICollectionViewCell {
    
    static let reuseIdentifier = "FeatureCell"
    
    // MARK: - UI Components
    private let gradientLayer = CAGradientLayer()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        imageView.tintColor = AppColors.accent
        imageView.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        imageView.layer.cornerRadius = 24
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppColors.accent
        label.numberOfLines = 2
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = FontFamily.Inter.regular(size: 13)
        label.numberOfLines = 1
        return label
    }()
    
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
        gradientLayer.frame = bounds
    }
    
    // MARK: - Configuration
    func configure(with item: FeatureItem) {
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        actionButton.isHidden = !item.hasActionButton
        
        // Мапим строковое имя иконки из чистой модели в UIImage из UI-кита 🌟
        switch item.type {
        case .turnPhotoToVideo:
            iconImageView.image = AppIcons.MainPage.turnPhotoToVideo
        case .fixWriting:
            iconImageView.image = AppIcons.MainPage.fixWriting
        case .summarize:
            iconImageView.image = AppIcons.MainPage.summarize
        }
        
        if item.isGradient {
            // Левая большая карточка
            backgroundColor = .clear
            gradientLayer.isHidden = false
            subtitleLabel.textColor = AppColors.accent.withAlphaComponent(0.6)
            titleLabel.font = FontFamily.Inter.medium(size: 20) // Крупный размер 20
        } else {
            // Правые карточки
            backgroundColor = AppColors.card
            gradientLayer.isHidden = true
            subtitleLabel.textColor = AppColors.placeholderText
            titleLabel.font = FontFamily.Inter.medium(size: 16) // Аккуратный размер 16
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
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.isHidden = true
        layer.insertSublayer(gradientLayer, at: 0)
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(actionButton)
    }
    
    private func setupConstraints() {
        iconImageView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(20)
            make.width.height.equalTo(48) // Идеальный круг под cornerRadius = 24
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        actionButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-16)
            make.height.equalTo(32)
        }
    }
}
