//
//  ChatAICell.swift
//  TestTask
//
//  Created by Vit Chernuhin on 30.06.2026.
//

import UIKit
import SnapKit

final class ChatAICell: UICollectionViewCell {
    
    // MARK: - UI Components
    private let bubbleView: UIView = {
        let view = UIView()
     
        view.backgroundColor = AppColors.typingBubbleBackground
        view.layer.cornerRadius = 24
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        view.clipsToBounds = true
        return view
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppColors.accent // Белый цвет текста по дизайну
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
            make.leading.equalTo(contentView).offset(28)
            make.trailing.lessThanOrEqualTo(contentView).offset(-28)
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

