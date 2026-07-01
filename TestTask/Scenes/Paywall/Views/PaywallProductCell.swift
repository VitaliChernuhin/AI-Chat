//
//  PaywallProductCell.swift
//  TestTask
//
//  Created by Vit Chernuhin on 01.07.2026.
//

import UIKit
import SnapKit

final class PaywallProductCell: UICollectionViewCell {
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColors.paywallCellBackground
        view.layer.cornerRadius = 20
        view.layer.borderWidth = 1
        view.layer.borderColor = AppColors.paywallCellBorder.cgColor
        view.clipsToBounds = true
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppColors.accent
        label.font = FontFamily.Inter.medium(size: 16)
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppColors.paywallPriceText
        label.font = FontFamily.Inter.regular(size: 14)
        return label
    }()
    
    // Розовый бейдж скидки (показываем только для годовой)
    private let badgeContainerView: PaywallBadgeGradientView = {
        let view = PaywallBadgeGradientView()
        view.layer.cornerRadius = 32
        view.clipsToBounds = true
        view.isHidden = true
        return view
    }()
    
    private let badgeLabel: UILabel = {
        let label = UILabel()
        label.text = "SAVE 80%"
        label.textColor = .white
        label.font = FontFamily.Inter.bold(size: 11)
        return label
    }()
    
    // Градиентная рамка для выбранного состояния
    private let gradientBorderLayer = CAGradientLayer()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        setupGradientBorder()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycle
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientBorderLayer.frame = containerView.bounds
        updateGradientBorderPath()
    }
}

// MARK: - Setup views (private)
private extension PaywallProductCell {
    func setupViews() {
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(priceLabel)
        containerView.addSubview(badgeContainerView)
        badgeContainerView.addSubview(badgeLabel)
    }
}

// MARK: - Setup constraints (private)
private extension PaywallProductCell {
    func setupConstraints() {
        // Контейнер карточки растягиваем по краям ячейки
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(containerView.snp.leading).offset(20)
            make.centerY.equalTo(containerView.snp.centerY)
        }
        
        priceLabel.snp.makeConstraints { make in
            make.trailing.equalTo(containerView.snp.trailing).offset(-20)
            make.centerY.equalTo(containerView.snp.centerY)
        }
        
        // Бейдж привязываем относительно titleLabel, но по центру containerView
        badgeContainerView.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(12)
            make.centerY.equalTo(containerView.snp.centerY)
            make.height.equalTo(20)
        }
        
        badgeLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(8)
            make.centerY.equalToSuperview()
        }
    }
}


// MARK: - Gradient border methods (private)
private extension PaywallProductCell {
    func setupGradientBorder() {
        gradientBorderLayer.colors = [AppColors.brandGradientStart.cgColor, AppColors.brandGradientEnd.cgColor]
        gradientBorderLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientBorderLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientBorderLayer.isHidden = true // По умолчанию скрыт, включаем только приisSelected
        
        // Создаем маску, чтобы красить только границу бордера, а не всю вьюху
        let maskLayer = CAShapeLayer()
        maskLayer.fillColor = UIColor.clear.cgColor
        maskLayer.strokeColor = UIColor.black.cgColor
        maskLayer.lineWidth = 2
        gradientBorderLayer.mask = maskLayer
        
        containerView.layer.addSublayer(gradientBorderLayer)
    }
    
    func updateGradientBorderPath() {
        guard let maskLayer = gradientBorderLayer.mask as? CAShapeLayer else { return }
        let path = UIBezierPath(roundedRect: containerView.bounds, cornerRadius: containerView.layer.cornerRadius)
        maskLayer.path = path.cgPath
    }
}

// MARK: - Public methods
extension PaywallProductCell {
    
    // MARK: - Configure
    func configure(title: String, price: String, badge: String?, isSelected: Bool) {
        titleLabel.text = title
        priceLabel.text = price
        
        if let badgeText = badge {
            badgeContainerView.isHidden = false
            badgeLabel.text = badgeText
        } else {
            badgeContainerView.isHidden = true
        }
        
        if isSelected {
            containerView.layer.borderColor = UIColor.clear.cgColor
            gradientBorderLayer.isHidden = false
        } else {
            containerView.layer.borderColor = AppColors.paywallCellBorder.cgColor
            gradientBorderLayer.isHidden = true
        }
    }
}
