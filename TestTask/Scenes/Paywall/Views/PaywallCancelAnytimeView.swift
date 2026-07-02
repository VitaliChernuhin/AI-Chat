//
//  PaywallCancelAnytimeView.swift
//  TestTask
//
//  Created by Vit Chernuhin on 01.07.2026.
//

import UIKit
import SnapKit

final class PaywallCancelAnytimeView: UIView {
    
    // MARK: - UI Components
    private let iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = AppIcons.Paywall.cancelAnyTime
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.text = "Cancel Anytime"
        label.textColor = AppColors.paywallPriceText
        label.font = FontFamily.Inter.regular(size: 12)
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

// MARK: - Setup (Private)
private extension PaywallCancelAnytimeView {
    
    func setupViews() {
        addSubview(iconView)
        addSubview(textLabel)
    }
    
    func setupConstraints() {
        iconView.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.width.height.equalTo(12)
        }
        
        textLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconView.snp.trailing).offset(4)
            make.trailing.top.bottom.equalToSuperview()
        }
    }
}
