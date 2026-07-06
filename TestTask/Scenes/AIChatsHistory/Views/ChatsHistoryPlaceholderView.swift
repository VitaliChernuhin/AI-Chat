//
//  ChatsHistoryPlaceholderView.swift
//  TestTask
//
//  Created by Vit Chernuhin on 06.07.2026.
//

import UIKit
import SnapKit

final class ChatsHistoryPlaceholderView: UIView {
    
    // MARK: - UI Components
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = AppIcons.ChatsHistory.placeholder
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppColors.accent
        label.font = FontFamily.Inter.bold(size: 28)
        label.textAlignment = .center
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppColors.chatsHistorySubtitleText
        label.font = FontFamily.Inter.regular(size: 16)
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
        stack.distribution = .fill
        return stack
    }()
    
    // MARK: - Init
    // Тексты теперь прилетают снаружи динамически!
    init(title: String, subtitle: String) {
        super.init(frame: .zero)
        
        // Накатываем тексты на лейблы со старта в памяти
        titleLabel.text = title
        subtitleLabel.text = subtitle
        
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup (private)
private extension ChatsHistoryPlaceholderView {
    func setupViews() {
        addSubview(iconImageView) // Выносим иконку из стека на уровень addSubview для твоих констрейнтов!
        addSubview(stackView)
        
        // В стеке остаются только текстовые блоки
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
    }
    
    func setupConstraints() {
        iconImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.height.equalTo(60)
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}
