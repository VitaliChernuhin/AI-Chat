//
//  ChatTypingIndicatorCell.swift
//  TestTask
//
//  Created by Vit Chernuhin on 26.06.2026.
//

import UIKit
import SnapKit

final class ChatTypingIndicatorCell: UICollectionViewCell {
    
    // MARK: - UI Components
    private let bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColors.typingBubbleBackground
        view.layer.cornerRadius = 24
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        view.clipsToBounds = true
        return view
    }()
    
    private let dotsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        stack.distribution = .fill // Даем каждой точке иметь свой уникальный размер
        return stack
    }()
    
    private let firstDotView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.createGradientCircle(size: CGSizeMake(19, 19))
        imageView.layer.cornerRadius = 9.5
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let secondDotView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColors.typingDotColor
        view.layer.cornerRadius = 7.5 // Половина от 15
        return view
    }()
    
    private let thirdDotView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColors.typingDotColor
        view.layer.cornerRadius = 5.0 // Половина от 10
        return view
    }()
    
    private let gradientLayer = CAGradientLayer()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        stopAnimating()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = firstDotView.bounds
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        // Ячейка сама управляет анимацией при появлении/уходе с экрана
        if window != nil {
            startAnimating()
        } else {
            stopAnimating()
        }
    }
    
    // MARK: - Setup
    private func setupViews() {
        contentView.addSubview(bubbleView)
        bubbleView.addSubview(dotsStackView)
        
        dotsStackView.addArrangedSubview(firstDotView)
        dotsStackView.addArrangedSubview(secondDotView)
        dotsStackView.addArrangedSubview(thirdDotView)
    }
    
    private func setupConstraints() {
        bubbleView.snp.makeConstraints { make in
            make.top.bottom.equalTo(contentView)
            make.leading.equalTo(contentView).offset(16)
            make.height.equalTo(51)
            make.width.equalTo(84)
        }
        
        dotsStackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(19) // По высоте самой большой точки
        }
        
        // Жестко требуем от автолайаута сохранить размеры, запрещая сжатие
        firstDotView.snp.makeConstraints { make in
            make.width.height.equalTo(19).priority(.required)
        }
        
        secondDotView.snp.makeConstraints { make in
            make.width.height.equalTo(15).priority(.required)
        }
        
        thirdDotView.snp.makeConstraints { make in
            make.width.height.equalTo(10).priority(.required)
        }
    }
}

// MARK: - Animation Logic
extension ChatTypingIndicatorCell {
    func startAnimating() {
        stopAnimating()
        
        let views = [firstDotView, secondDotView, thirdDotView]
        
        for (index, dotView) in views.enumerated() {
            dotView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            
            UIView.animate(
                withDuration: 0.5,
                delay: Double(index) * 0.15,
                options: [.repeat, .autoreverse, .curveEaseInOut],
                animations: {
                    dotView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                    if index == 1 || index == 2 {
                        dotView.alpha = 0.6
                    }
                },
                completion: nil
            )
        }
    }
    
    func stopAnimating() {
        [firstDotView, secondDotView, thirdDotView].enumerated().forEach { index, dotView in
            dotView.layer.removeAllAnimations()
            dotView.transform = .identity
            if index > 0 {
                dotView.alpha = index == 1 ? 0.4 : 0.2
            }
        }
    }
}

// MARK: - UIImage Gradient Helper
private extension UIImage {
    static func createGradientCircle(size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = CGRect(origin: .zero, size: size)
            gradientLayer.colors = [
                UIColor(red: 0.55, green: 0.60, blue: 0.90, alpha: 1.0).cgColor,
                UIColor(red: 0.77, green: 0.35, blue: 0.52, alpha: 1.0).cgColor
            ]
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
            
            // Отрисовываем градиент в контекст картинки
            gradientLayer.render(in: context.cgContext)
        }
    }
}
