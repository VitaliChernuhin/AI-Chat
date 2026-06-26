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
    private let bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
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
    
    private let gradientLayer = CAGradientLayer()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        setupGradient()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Обновление для градиента
        contentView.layoutIfNeeded()
        gradientLayer.frame = bubbleView.bounds
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
    
    private func setupGradient() {
        gradientLayer.colors = [
            UIColor(red: 0.55, green: 0.60, blue: 0.90, alpha: 1.0).cgColor,
            UIColor(red: 0.77, green: 0.35, blue: 0.52, alpha: 1.0).cgColor
        ]
        // Горизонтальное направление градиента слева направо
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        bubbleView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    // MARK: - Configure
    func configure(with message: ChatMessageItem) {
        messageLabel.text = message.text
    }
}
