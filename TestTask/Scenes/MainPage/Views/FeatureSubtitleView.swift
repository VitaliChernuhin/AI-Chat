//
//  FeatureSubtitleView.swift
//  TestTask
//
//  Created by Vit Chernuhin on 21.06.2026.
//

import UIKit
import SnapKit

final class FeatureSubtitleView: UIView {
    
    // MARK: - UI Components
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.alignment = .center
        stack.spacing = 8
        return stack
    }()
    
    private let leftLabel = UILabel()
    private let rightLabel = UILabel()
    
    private let dotImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = AppIcons.MainPage.bulletDot
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    // MARK: - Setup
    private func setupView() {
        addSubview(stackView)
        stackView.addArrangedSubview(leftLabel)
        stackView.addArrangedSubview(dotImageView)
        stackView.addArrangedSubview(rightLabel)
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // Точка жестко зафиксирована 4х4 и центрирована с микро-сдвигом вниз
        dotImageView.snp.makeConstraints { make in
            make.width.height.equalTo(4)
            make.centerY.equalToSuperview().offset(1)
        }
        
        leftLabel.setContentHuggingPriority(.required, for: .horizontal)
        rightLabel.setContentHuggingPriority(.required, for: .horizontal)

        leftLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        rightLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    
    // MARK: - Configuration
    func configure(with parts: [String], font: UIFont, textColor: UIColor) {
        guard parts.count >= 2 else { return }
        
        leftLabel.text = parts[0]
        leftLabel.font = font
        leftLabel.textColor = textColor
        
        rightLabel.text = parts[1]
        rightLabel.font = font
        rightLabel.textColor = textColor
        
        dotImageView.tintColor = textColor
        dotImageView.alpha = 0.7
    }
}
