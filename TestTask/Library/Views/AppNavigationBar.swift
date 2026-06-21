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
    
    // MARK: - UI Components
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        if let image = AppIcons.NavigationBar.back {
            button.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
        }
        button.tintColor = AppColors.accent
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppColors.accent
        label.font = FontFamily.Inter.semiBold(size: 20)
        label.textAlignment = .center
        return label
    }()
    
    private let rightButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = AppColors.accent
        button.isHidden = true
        return button
    }()
    
    // MARK: - Init
    init(title: String, rightImage: UIImage? = nil) {
        super.init(frame: .zero)
        titleLabel.text = title
        
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
        addSubview(titleLabel)
        addSubview(rightButton)
    }
    
    private func setupConstraints() {
        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-8)
            make.width.height.equalTo(40)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(backButton.snp.centerY)
            make.centerX.equalToSuperview()
            make.leading.equalTo(backButton.snp.trailing).offset(16)
            make.trailing.equalTo(rightButton.snp.leading).offset(-16)
        }
        
        rightButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(backButton.snp.centerY)
            make.width.height.equalTo(40)
        }
    }
    
    private func setupActions() {
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    }
    
    @objc private func backButtonTapped() {
        onBackTapped?()
    }
}

