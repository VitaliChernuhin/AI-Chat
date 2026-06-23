//
//  ChatInputView.swift
//  TestTask
//
//  Created by Vit Chernuhin on 23.06.2026.
//

import UIKit
import SnapKit

final class ChatInputView: UIView {
    
    // MARK: - States
    enum State {
        /// Клавиатура скрыта, текст пустой [Стрелка + Микрофон]
        case normal
        /// Клавиатура поднята, текст пустой [Только Стрелка]
        case editingEmpty
        /// Клавиатура поднята, текст введен [Только Самолётик]
        case editingWithText
    }
    
    var onSendTapped: ((String) -> Void)?
    var onArrowTapped: (() -> Void)?
    var onStateChanged: ((State) -> Void)?
    
    private var arrowTrailingConstraint: Constraint?
    
    private(set) var currentState: State = .normal
    
    // MARK: - UI Components
    private let textField: UITextField = {
        let field = UITextField()
        field.textColor = AppColors.accent
        field.font = FontFamily.Inter.regular(size: 16) // 16px по макету Figma
        return field
    }()
    
    private let arrowDownButton: UIButton = {
        let button = UIButton(type: .system)
        if let image = AppIcons.Chat.arrowDown {
            button
                .setImage(
                    image.withRenderingMode(.alwaysTemplate),
                    for: .normal
                )
        }
        button.tintColor = AppColors.accent
        button.backgroundColor = .clear
        button.layer.borderWidth = 1.0
        button.layer.borderColor = AppColors.chatInputBorder.cgColor
        return button
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        if let image = AppIcons.Chat.paperplane {
            button
                .setImage(
                    image.withRenderingMode(.alwaysTemplate),
                    for: .normal
                )
        }
        button.tintColor = .white
        return button
    }()
    
    private let microphoneButton: UIButton = {
        let button = UIButton(type: .system)
        if let image = AppIcons.Chat.microphone {
            button
                .setImage(
                    image.withRenderingMode(.alwaysTemplate),
                    for: .normal
                )
        }
        button.tintColor = AppColors.accent
        button.backgroundColor = .clear
        button.layer.borderWidth = 1.0
        button.layer.borderColor = AppColors.chatInputBorder.cgColor
        return button
    }()
    
    private let sendButtonGradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 0.55, green: 0.60, blue: 0.90, alpha: 1.0).cgColor,
            UIColor(red: 0.77, green: 0.35, blue: 0.52, alpha: 1.0).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        return gradient
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
        setupActions()
        updateUI(for: .normal, animated: false) // Стартуем в состоянии .normal
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        let radius = arrowDownButton.bounds.width / 2
        arrowDownButton.layer.cornerRadius = radius
        microphoneButton.layer.cornerRadius = radius
        sendButton.layer.cornerRadius = radius
        sendButton.clipsToBounds = true
        
        sendButtonGradientLayer.frame = sendButton.bounds
        sendButton.layer.insertSublayer(sendButtonGradientLayer, at: 0)
    }
    
    // MARK: - Private Setup
    private func setupView() {
        backgroundColor = AppColors.chatAskAnythingBackground
        
        // Оставляем скругления только сверху шторки
        layer.cornerRadius = 24
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        layer.masksToBounds = true
        
        addSubview(textField)
        addSubview(arrowDownButton)
        addSubview(sendButton)
        addSubview(microphoneButton)
        
        // Вставляем градиент строго под иконку самолётика, чтобы она не перекрывалась
        if let imageView = sendButton.imageView {
            sendButton.layer
                .insertSublayer(sendButtonGradientLayer, below: imageView.layer)
        } else {
            sendButton.layer.insertSublayer(sendButtonGradientLayer, at: 0)
        }
    }
    
    private func setupConstraints() {
        // Микрофон НАМЕРТВО привязан к правому краю
        microphoneButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(textField.snp.centerY)
            make.width.height.equalTo(40)
        }
        
        // Стрелка привязана к микрофону, но мы сохраняем ссылку на констрейнт
        arrowDownButton.snp.makeConstraints { make in
            self.arrowTrailingConstraint = make.trailing.equalTo(microphoneButton.snp.leading).offset(-12).constraint
            make.centerY.equalTo(textField.snp.centerY)
            make.width.height.equalTo(40)
        }
        
        sendButton.snp.makeConstraints { make in
            make.edges.equalTo(arrowDownButton)
        }
        
        textField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.height.equalTo(44)
            make.centerY.equalToSuperview()
            make.trailing.equalTo(arrowDownButton.snp.leading).offset(-12)
        }
    }
    
    
    private func setupActions() {
        textField
            .addTarget(
                self,
                action: #selector(textFieldDidChange),
                for: .editingChanged
            )
        textField
            .addTarget(
                self,
                action: #selector(textFieldDidBeginEditing),
                for: .editingDidBegin
            )
        textField
            .addTarget(
                self,
                action: #selector(textFieldDidEndEditing),
                for: .editingDidEnd
            )
        
        arrowDownButton
            .addTarget(
                self,
                action: #selector(arrowButtonTapped),
                for: .touchUpInside
            )
        sendButton
            .addTarget(
                self,
                action: #selector(sendButtonTapped),
                for: .touchUpInside
            )
    }
    
    // MARK: - Public State Management
    
    func updateUI(for state: State, animated: Bool = true) {
        currentState = state
        
        let block = { [weak self] in
            guard let self = self else { return }
            
            switch state {
            case .normal:
                self.setPlaceholder("How can I help you?")
                self.microphoneButton.alpha = 1.0
                self.arrowDownButton.alpha = 1.0
                self.sendButton.alpha = 0.0
                
                // Возвращаем отступ назад (-12pt от микрофона)
                self.arrowTrailingConstraint?.update(offset: -12)
                
                self.textField.snp.updateConstraints { make in
                    make.centerY.equalToSuperview().offset(-10)
                }
                
            case .editingEmpty:
                self.setPlaceholder("Ask anything...")
                self.microphoneButton.alpha = 0.0
                self.arrowDownButton.alpha = 1.0
                self.sendButton.alpha = 0.0
                
                // Сдвигаем стрелку в самый край поверх прозрачного микрофона!
                // Ширина микрофона (40) + его старый отступ (12) = 52pt сдвиг вперед
                self.arrowTrailingConstraint?.update(offset: 52)
                
                self.textField.snp.updateConstraints { make in
                    make.centerY.equalToSuperview()
                }
                
            case .editingWithText:
                self.setPlaceholder("Ask anything...")
                self.microphoneButton.alpha = 0.0
                self.arrowDownButton.alpha = 0.0
                self.sendButton.alpha = 1.0
                
                // Самолётик остаётся в правом углу
                self.arrowTrailingConstraint?.update(offset: 52)
                
                self.textField.snp.updateConstraints { make in
                    make.centerY.equalToSuperview()
                }
            }
            self.layoutIfNeeded()
        }
        
        if animated {
            UIView.animate(withDuration: 0.2, animations: block)
        } else {
            block()
        }
        
        onStateChanged?(state)
    }
    
    
    private func setPlaceholder(_ text: String) {
        textField.attributedPlaceholder = NSAttributedString(
            string: text,
            attributes: [NSAttributedString.Key.foregroundColor: AppColors.chatInputPlaceholderText]
        )
    }
    
    // MARK: - Handlers
    @objc private func textFieldDidChange(_ textField: UITextField) {
        let isTextEmpty = textField.text?.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty ?? true
        updateUI(for: isTextEmpty ? .editingEmpty : .editingWithText)
    }
    
    @objc private func textFieldDidBeginEditing(_ textField: UITextField) {
        let isTextEmpty = textField.text?.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty ?? true
        updateUI(for: isTextEmpty ? .editingEmpty : .editingWithText)
    }
    
    @objc private func textFieldDidEndEditing(_ textField: UITextField) {
        let isTextEmpty = textField.text?.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty ?? true
        updateUI(for: isTextEmpty ? .normal : .editingWithText)
    }
    
    @objc private func arrowButtonTapped() {
        onArrowTapped?()
    }
    
    @objc private func sendButtonTapped() {
        guard let text = textField.text, !text.isEmpty else { return }
        onSendTapped?(text)
        textField.text = ""
        textField.endEditing(true)
    }
}
