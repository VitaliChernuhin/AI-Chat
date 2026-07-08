//
//  AppNavigationBar.swift
//  TestTask
//
//  Created by Vit Chernuhin on 21.06.2026.
//

import UIKit
import SnapKit

final class AppNavigationBar: UIView {
    
    var onBackTapped: (() -> Void)?
    var onRightTapped: (() -> Void)?
    
    var subtitle: String? {
        didSet {
            if let subtitle = subtitle, !subtitle.isEmpty {
                subtitleLabel.text = subtitle
                subtitleLabel.isHidden = false
            } else {
                subtitleLabel.text = nil
                subtitleLabel.isHidden = true
            }
        }
    }
    
    // MARK: - UI Components
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        if let image = AppIcons.NavigationBar.back {
            button.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
        }
        button.tintColor = AppColors.accent
        return button
    }()
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()
    
    private let titleContainerStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 2
        return stack
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppColors.accent
        label.font = FontFamily.Inter.semiBold(size: 20)
        label.textAlignment = .center
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppColors.navBarSubtitle
        label.font = FontFamily.Inter.regular(size: 14)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private let rightButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = AppColors.accent
        button.isHidden = true
        return button
    }()
    
    // MARK: - Init
    init(title: String, subtitle: String? = nil, avatarImage: UIImage? = nil, rightImage: UIImage? = nil) {
        super.init(frame: .zero)
        
        titleLabel.text = title
        
        if let subtitle = subtitle {
            subtitleLabel.text = subtitle
            subtitleLabel.isHidden = false
        }
        
        if let avatarImage = avatarImage {
            avatarImageView.image = avatarImage
            avatarImageView.isHidden = false
        }
        
        if let rightImage = rightImage {
            rightButton.setImage(rightImage.withRenderingMode(.alwaysTemplate), for: .normal)
            rightButton.isHidden = false
        }
        
        setupView()
        setupConstraints()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupView() {
        backgroundColor = AppColors.navBarBackground
        
        addSubview(backButton)
        addSubview(avatarImageView)
        addSubview(titleContainerStackView)
        addSubview(rightButton)
        
        titleContainerStackView.addArrangedSubview(titleLabel)
        titleContainerStackView.addArrangedSubview(subtitleLabel)
    }
    
    private func setupConstraints() {
        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-16) // Отступ 16pt снизу панели (высота стандартной рабочей зоны 44pt)
            make.width.height.equalTo(24)
        }
        
        avatarImageView.snp.makeConstraints { make in
            make.leading.equalTo(backButton.snp.trailing).offset(32)
            make.centerY.equalTo(backButton.snp.centerY)
            make.width.height.equalTo(32)
        }
        
        rightButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(backButton.snp.centerY)
            make.width.height.equalTo(24)
        }
        
        titleContainerStackView.snp.makeConstraints { make in
            make.centerY.equalTo(backButton.snp.centerY)
            
            if avatarImageView.isHidden {
                make.centerX.equalToSuperview()
                make.leading.greaterThanOrEqualTo(backButton.snp.trailing).offset(32)
                make.trailing.lessThanOrEqualTo(rightButton.snp.leading).offset(-8)
            } else {
                make.leading.equalTo(avatarImageView.snp.trailing).offset(12)
                make.trailing.lessThanOrEqualTo(rightButton.snp.leading).offset(-8)
            }
        }
    }
    
    private func setupActions() {
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(rightButtonTapped), for: .touchUpInside)
    }
    
    @objc private func backButtonTapped() {
        onBackTapped?()
    }
    
    @objc private func rightButtonTapped() {
        onRightTapped?()
    }
}
