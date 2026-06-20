//
//  BackgroundView.swift
//  TestTask
//
//  Created by Vit Chernuhin on 20.06.2026.
//

import UIKit
import SnapKit

final class BackgroundView: UIView {
    
    // MARK: - UI Components
    private let baseGradientLayer = CAGradientLayer()
    private let topRightGlowView = UIView()
    private let topLeftGlowView = UIView()
    private let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        // Обновляем фрейм градиента под актуальные размеры экрана
        baseGradientLayer.frame = bounds
        
        // Пересчитываем скругление для создания круглых пятен свечения
        topRightGlowView.layer.cornerRadius = topRightGlowView.bounds.width / 2
        topLeftGlowView.layer.cornerRadius = topLeftGlowView.bounds.width / 2
    }
    
    // MARK: - Setup
    private func setupView() {
        clipsToBounds = true
        
        // 1. Базовый темный градиент
        baseGradientLayer.colors = [
            UIColor(red: 0.10, green: 0.07, blue: 0.14, alpha: 1.0).cgColor,
            UIColor(red: 0.05, green: 0.04, blue: 0.06, alpha: 1.0).cgColor
        ]
        baseGradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        baseGradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        layer.addSublayer(baseGradientLayer)
        
        // 2. Розово-фиолетовое свечение справа вверху
        topRightGlowView.backgroundColor = UIColor(red: 0.50, green: 0.25, blue: 0.45, alpha: 0.4)
        addSubview(topRightGlowView)
        
        // 3. Сине-серое свечение слева вверху
        topLeftGlowView.backgroundColor = UIColor(red: 0.25, green: 0.30, blue: 0.40, alpha: 0.25)
        addSubview(topLeftGlowView)
        
        // 4. Эффект размытия для создания мягкого "Aurora" градиента
        blurEffectView.frame = bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.alpha = 0.95
        addSubview(blurEffectView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        // Правое верхнее розовое свечение
        topRightGlowView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-50)
            make.trailing.equalToSuperview().offset(50)
            make.width.height.equalToSuperview().multipliedBy(0.8)
        }
        
        // Левое верхнее синее свечение
        topLeftGlowView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-30)
            make.leading.equalToSuperview().offset(-50)
            make.width.height.equalToSuperview().multipliedBy(0.6)
        }
    }
}

