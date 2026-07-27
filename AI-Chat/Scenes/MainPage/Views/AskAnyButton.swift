//
//  AskAnyButton.swift
//  TestTask
//
//  Created by Vit Chernuhin on 21.06.2026.
//

import UIKit
import SnapKit

final class AskAnyButton: UIButton {
    
    // MARK: - UI Components
    private let gradientUnderlay: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.layer.cornerRadius = 24
        view.clipsToBounds = true
        return view
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        // Настраиваем идеальный градиентный ободок
        applyGradientBorder()
    }
    
    // MARK: - Setup
    private func setupButton() {
        backgroundColor = AppColors.askAnyBackground
        // ОБНОВИЛИ: Делаем кнопку капсульной, как на макете
        layer.cornerRadius = 24
        
        var config = UIButton.Configuration.plain()
        config.title = "Ask anything..."
        config.baseForegroundColor = AppColors.placeholderText
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = FontFamily.Inter.regular(size: 16)
            return outgoing
        }
        
        if let iconImage = AppIcons.MainPage.askAny {
            config.image = iconImage.withRenderingMode(.alwaysOriginal)
        }
        config.imagePlacement = .leading
        config.imagePadding = 16
        // Чуть увеличиваем отступ слева, так как кнопка стала круглее
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 18.5)
        
        configuration = config
        contentHorizontalAlignment = .left
        
        // Добавляем подложку на самый задний план
        insertSubview(gradientUnderlay, at: 0)
    }
    
    private func setupConstraints() {
        // Подложка идеально заполняет всю площадь кнопки
        gradientUnderlay.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: - Gradient Border
    private func applyGradientBorder() {
        gradientUnderlay.layer.sublayers?.filter { $0.name == "MainGradientBorder" }.forEach { $0.removeFromSuperlayer() }
        
        let radius: CGFloat = 24
        
        let borderPath = UIBezierPath(roundedRect: gradientUnderlay.bounds, cornerRadius: radius)
        
        let shapeMask = CAShapeLayer()
        shapeMask.path = borderPath.cgPath
        shapeMask.fillColor = UIColor.clear.cgColor
        shapeMask.strokeColor = UIColor.black.cgColor
        shapeMask.lineWidth = 2.0
        
        //Горизонтальный неоновый градиент
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = gradientUnderlay.bounds
        gradientLayer.colors = [
            UIColor(red: 0.31, green: 0.37, blue: 0.48, alpha: 0.85).cgColor,
            UIColor(red: 0.46, green: 0.24, blue: 0.37, alpha: 0.85).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.mask = shapeMask
        
        // 3. Зеркальная ультра-четкая маска отсечения боковин
        let fadeMask = CAGradientLayer()
        fadeMask.frame = gradientUnderlay.bounds
        fadeMask.startPoint = CGPoint(x: 0.0, y: 0.5)
        fadeMask.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        fadeMask.colors = [
            UIColor.clear.cgColor,  // Слева полностью невидимо
            UIColor.white.cgColor,  // Мгновенный переход в 100% видимость
            UIColor.white.cgColor,  // Держим сочность по всему центру
            UIColor.clear.cgColor   // Мгновенный переход обратно в прозрачность справа
        ]
        
        fadeMask.locations = [0.005, 0.006, 0.994, 0.995]
        
        let containerLayer = CALayer()
        containerLayer.name = "MainGradientBorder"
        containerLayer.frame = gradientUnderlay.bounds
        containerLayer.addSublayer(gradientLayer)
        containerLayer.mask = fadeMask
        
        gradientUnderlay.layer.addSublayer(containerLayer)
    }
}



