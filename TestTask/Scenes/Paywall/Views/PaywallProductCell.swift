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
        view.layer.cornerRadius = 24
        view.layer.borderWidth = 1
        view.layer.borderColor = AppColors.paywallCellBorder.cgColor
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, priceLabel])
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .leading
        stack.spacing = 4
        return stack
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
        view.layer.cornerRadius = 12.5
        view.clipsToBounds = true
        view.isHidden = true
        return view
    }()
    
    private let badgeLabel: UILabel = {
        let label = UILabel()
        label.text = "SAVE 80%"
        label.textColor = AppColors.accent
        label.font = FontFamily.Inter.medium(size: 14)
        label.textAlignment = .center
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
        
        updateGradientBorderGeometry()
    }
}

// MARK: - Setup views (private)
private extension PaywallProductCell {
    func setupViews() {
        contentView.addSubview(containerView)
        containerView.addSubview(stackView)
        containerView.addSubview(badgeContainerView)
        badgeContainerView.addSubview(badgeLabel)
    }
}

// MARK: - Setup constraints (private)
private extension PaywallProductCell {
    func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(24)
            make.trailing.lessThanOrEqualToSuperview().offset(-16)
        }
        
        badgeContainerView.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.top)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(25)
            make.width.equalTo(102)
        }
        
        badgeLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(8)
            make.centerY.equalTo(badgeContainerView.snp.centerY)
        }
    }
}

// MARK: - Gradient border methods (private)
private extension PaywallProductCell {
    
    func setupGradientBorder() {
        gradientBorderLayer.colors = [AppColors.brandGradientStart.cgColor, AppColors.brandGradientEnd.cgColor]
        gradientBorderLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientBorderLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientBorderLayer.isHidden = true
        
        let maskLayer = CAShapeLayer()
        maskLayer.fillColor = UIColor.clear.cgColor
        maskLayer.strokeColor = UIColor.black.cgColor
        maskLayer.lineWidth = 1
        gradientBorderLayer.mask = maskLayer
        
        containerView.layer.addSublayer(gradientBorderLayer)
    }
    
    func updateGradientBorderGeometry() {
        containerView.layoutIfNeeded()
        gradientBorderLayer.frame = containerView.bounds
        
        guard let maskLayer = gradientBorderLayer.mask as? CAShapeLayer else { return }
        
        let insetBounds = containerView.bounds.insetBy(dx: 0.5, dy: 0.5)
        
        // Это идеально компенсирует затягивание дуги и заставит градиент лечь
        // точь-в-точь по контуру родного скругления карточки!
        let targetRadius = containerView.layer.cornerRadius - 1
        
        let path = UIBezierPath(
            roundedRect: insetBounds,
            byRoundingCorners: .allCorners,
            cornerRadii: CGSize(width: targetRadius, height: targetRadius)
        )
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
