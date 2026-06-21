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

    private let baseBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColors.background
        return view
    }()
    
    // Горизонтальный цветной градиент (синий -> пурпурный)
    private let colorGradientLayer = CAGradientLayer()
    private let colorContainerView = UIView()
    
    // Маска для плавного затухания цвета сверху вниз
    private let maskGradientLayer = CAGradientLayer()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupConstraints()
    }
    
    // MARK: - Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Обновляем размеры цветного градиента под верхнюю область
        colorGradientLayer.frame = colorContainerView.bounds
        
        // Обновляем маску прозрачности
        maskGradientLayer.frame = colorContainerView.bounds
    }
    
    // MARK: - Setup
    private func setupView() {
        clipsToBounds = true
        addSubview(baseBackgroundView)
        addSubview(colorContainerView)
        
        // 1. Настраиваем горизонтальный градиент (слева направо)
        colorGradientLayer.colors = [
            UIColor(red: 0.31, green: 0.37, blue: 0.48, alpha: 0.65).cgColor, // Левый стальной синий
            UIColor(red: 0.46, green: 0.24, blue: 0.37, alpha: 0.75).cgColor  // Правый пурпурный
        ]
        colorGradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        colorGradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        colorContainerView.layer.addSublayer(colorGradientLayer)
        
        // 2. Настраиваем маску затухания по вертикали (сверху вниз)
        // Непрозрачный белый цвет вверху сохраняет яркость, черный внизу полностью её стирает
        maskGradientLayer.colors = [
            UIColor.white.cgColor,
            UIColor.white.withAlphaComponent(0.5).cgColor,
            UIColor.clear.cgColor
        ]
        // Пропорции затухания: до 20% высоты держим цвет, к 100% плавно гасим в ноль
        maskGradientLayer.locations = [0.0, 0.2, 1.0]
        maskGradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        maskGradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        // Применяем маску к контейнеру с цветами
        colorContainerView.layer.mask = maskGradientLayer
    }
    
    // MARK: - Constraints (SnapKit)
    private func setupConstraints() {
        baseBackgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // Контейнер занимает только верхнюю треть экрана
        colorContainerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.35)
        }
    }
}



