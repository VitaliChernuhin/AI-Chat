//
//  ChatUserCell.swift
//  TestTask
//
//  Created by Vit Chernuhin on 26.06.2026.
//

import UIKit
import SnapKit

final class ChatUserCell: UICollectionViewCell {
    
    // MARK: - UI Components
    private let bubbleView: GradientView = {
        let view = GradientView()
        view.layer.cornerRadius = 24
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
        view.clipsToBounds = true
        return view
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppColors.accent
        label.font = FontFamily.Inter.regular(size: 16)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Setup
    private func setupViews() {
        contentView.addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)
    }
    
    private func setupConstraints() {
        bubbleView.snp.makeConstraints { make in
            make.top.bottom.equalTo(contentView)
            make.trailing.equalTo(contentView).offset(-16)
            make.leading.greaterThanOrEqualTo(contentView).offset(16)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }
    
    // MARK: - Configure
    func configure(with message: ChatMessageItem) {
        messageLabel.text = message.text
    }
}

// MARK: - Кастомный инкапсулированный GradientView (Секрет плавности)
private final class GradientView: UIView {
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    var gradientLayer: CAGradientLayer {
        return layer as! CAGradientLayer
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupGradient() {
        gradientLayer.colors = [AppColors.brandGradientStart.cgColor, AppColors.brandGradientEnd.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
    }
}
