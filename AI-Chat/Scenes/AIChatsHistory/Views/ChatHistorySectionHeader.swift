//
//  ChatHistorySectionHeader.swift
//  TestTask
//
//  Created by Vit Chernuhin on 06.07.2026.
//

import UIKit
import SnapKit

final class ChatHistorySectionHeader: UICollectionReusableView {
    
    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppColors.accent
        label.font = FontFamily.Inter.semiBold(size: 20)
        label.textAlignment = .left
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
}

// MARK: - Setup views (private)
private extension ChatHistorySectionHeader {
    func setupViews() {
        backgroundColor = .clear
        addSubview(titleLabel)
    }
}

// MARK: - Setup constraints (private)
private extension ChatHistorySectionHeader {
    func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: - Public Configure Method
extension ChatHistorySectionHeader {
    func configure(title: String) {
        titleLabel.text = title
    }
}
