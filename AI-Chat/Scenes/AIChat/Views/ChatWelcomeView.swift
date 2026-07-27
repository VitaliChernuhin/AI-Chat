//
//  ChatWelcomeView.swift
//  TestTask
//
//  Created by Vit Chernuhin on 24.06.2026.
//

import UIKit
import SnapKit

final class ChatWelcomeView: UIView {
    
    // MARK: - UI Components
    private let welcomeStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        return stack
    }()
    
    private let welcomeTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 1
        label.font = FontFamily.Inter.semiBold(size: 20)
        label.textColor = AppColors.accent
        return label
    }()
    
    private let welcomeSubtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppColors.welcomeSubtitle
        label.font = FontFamily.Inter.regular(size: 14)
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    // MARK: - Init
    init(attributedTitle: NSAttributedString, subtitle: String) {
        super.init(frame: .zero)
        setupViews()
        setupConstraints()
        
        welcomeTitleLabel.attributedText = attributedTitle
        welcomeSubtitleLabel.text = subtitle
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(welcomeStackView)
        welcomeStackView.addArrangedSubview(welcomeTitleLabel)
        welcomeStackView.addArrangedSubview(welcomeSubtitleLabel)
    }
    
    private func setupConstraints() {
        welcomeStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
