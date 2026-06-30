//
//  AppAlertView.swift
//  TestTask
//
//  Created by Vit Chernuhin on 27.06.2026.
//

import UIKit
import SnapKit

final class AppAlertView: UIView {
    
    enum AlertType {
        case success
        case error
    }
    
    // MARK: - UI Components
    private let backgroundOverlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        return view
    }()
    
    private let alertContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColors.alertBackground
        view.layer.cornerRadius = 24
        view.clipsToBounds = true
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppColors.accent
        label.font = FontFamily.Inter.regular(size: 16)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    // MARK: - Init
    init(type: AlertType, message: String) {
        super.init(frame: .zero)
        setupViews()
        setupConstraints()
        configure(type: type, message: message)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupViews() {
        addSubview(backgroundOverlayView)
        addSubview(alertContainerView)
        
        alertContainerView.addSubview(iconImageView)
        alertContainerView.addSubview(messageLabel)
    }
    
    private func setupConstraints() {
        // Затемняющий оверлей на весь экран
        backgroundOverlayView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // Центральное окошко алерта фиксированного размера по дизайну
        alertContainerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(243)
            make.height.greaterThanOrEqualTo(158) // Растет вниз, если текст длинный
        }
        
        // Иконка по центру верха
        iconImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(28)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(32)
        }
        
        // Текст сообщения под иконкой
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().offset(-28)
        }
    }
    
    // MARK: - Configure
    private func configure(type: AlertType, message: String) {
        messageLabel.text = message
        
        switch type {
        case .success:
            iconImageView.image = AppIcons.Alert.successCheck
        case .error:
            iconImageView.image = AppIcons.Alert.errorWarning
        }
    }
}

// MARK: - Transition Animation Interface (Вызывается движком AppAlertTransitionAnimation)
extension AppAlertView {
    
    /// Скрывает элементы и сжимает окошко перед началом анимации появления
    func prepareForPresentationAnimation() {
        backgroundOverlayView.alpha = 0.0
        alertContainerView.alpha = 0.0
        alertContainerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    }
    
    /// Проявляет оверлей и возвращает окошко к реальному размеру 1.0
    func performPresentationAnimation() {
        backgroundOverlayView.alpha = 1.0
        alertContainerView.alpha = 1.0
        alertContainerView.transform = .identity
    }
    
    /// Гасит экран и сжимает окошко обратно в центр при закрытии
    func performDismissalAnimation() {
        backgroundOverlayView.alpha = 0.0
        alertContainerView.alpha = 0.0
        alertContainerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    }
}
