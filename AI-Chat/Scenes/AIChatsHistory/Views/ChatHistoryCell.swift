//
//  ChatHistoryCell.swift
//  TestTask
//
//  Created by Vit Chernuhin on 06.07.2026.
//

import UIKit
import SnapKit

final class ChatHistoryCell: UICollectionViewCell {
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColors.chatHistoryCellBackground
        view.layer.cornerRadius = 24
        view.clipsToBounds = true
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = AppIcons.ChatsHistory.historyItem
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let promptLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppColors.accent
        label.font = FontFamily.Inter.semiBold(size: 16)
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppColors.chatsHistorySubtitleText
        label.font = FontFamily.Inter.regular(size: 14)
        label.textAlignment = .left
        return label
    }()
    
    private let labelsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
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
}

// MARK: - Setup views (private)
private extension ChatHistoryCell {
    func setupViews() {
        contentView.addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(labelsStackView)
        
        labelsStackView.addArrangedSubview(promptLabel)
        labelsStackView.addArrangedSubview(timeLabel)
    }
}

// MARK: - Setup constraints (private)
private extension ChatHistoryCell {
    func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(28)
        }
        
        labelsStackView.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.centerY.equalToSuperview()
        }
    }
}

// MARK: - Public Configure Method
extension ChatHistoryCell {
    func configure(text: String, time: String) {
        promptLabel.text = text
        timeLabel.text = time
    }
}
