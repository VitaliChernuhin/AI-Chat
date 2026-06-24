//
//  ChatInputView.swift
//  TestTask
//
//  Created by Vit Chernuhin on 23.06.2026.
//

import UIKit
import SnapKit

final class ChatInputView: UIView {
    
    // MARK: - Constants
    private enum Constants {
        /// Максимальная высота текстового поля, соответствующая 3 строкам ввода
        static let maxTextViewHeight: CGFloat = 88.0
        /// Минимальная высота текстового поля для одной строки
        static let minTextViewHeight: CGFloat = 40.0
    }
    
    // MARK: - States
    enum State {
        /// Клавиатура скрыта, текст пустой [Стрелка + Micro]
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
    private let textView: UITextView = {
        let tv = UITextView()
        tv.textColor = AppColors.accent
        tv.font = FontFamily.Inter.regular(size: 16)
        tv.backgroundColor = .clear
        tv.isScrollEnabled = false // Ключевое свойство для автоматического роста вверх!
        
        // Срезаем системные внутренние поля, чтобы текст стоял вровень с кнопками
        tv.textContainer.lineFragmentPadding = 0
        tv.textContainerInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        return tv
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppColors.chatInputPlaceholderText
        label.font = FontFamily.Inter.regular(size: 16)
        return label
    }()
    
    private let arrowDownButton: UIButton = {
        let button = UIButton(type: .system)
        if let image = AppIcons.Chat.arrowDown {
            button.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
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
            button.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
        }
        button.tintColor = .white
        return button
    }()
    
    private let microphoneButton: UIButton = {
        let button = UIButton(type: .system)
        if let image = AppIcons.Chat.microphone {
            button.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
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
        updateUI(for: .normal, animated: false)
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
        layer.cornerRadius = 24
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        layer.masksToBounds = true
        
        addSubview(textView)
        addSubview(arrowDownButton)
        addSubview(sendButton)
        addSubview(microphoneButton)
        
        // Вставляем плейсхолдер поверх textView
        textView.addSubview(placeholderLabel)
        
        if let imageView = sendButton.imageView {
            sendButton.layer.insertSublayer(sendButtonGradientLayer, below: imageView.layer)
        } else {
            sendButton.layer.insertSublayer(sendButtonGradientLayer, at: 0)
        }
    }
    
    private func setupConstraints() {
        // 1. Микрофон центрируем по вертикали относительно первой строки ввода!
        microphoneButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16).priority(999)
            make.bottom.lessThanOrEqualTo(textView.snp.bottom) // Ограничитель
            make.height.equalTo(40)
            make.width.equalTo(40)
        }
        
        // 2. Стрелка дублирует позицию микрофона
        arrowDownButton.snp.makeConstraints { make in
            self.arrowTrailingConstraint = make.trailing.equalTo(microphoneButton.snp.leading).constraint
            make.bottom.equalTo(microphoneButton.snp.bottom)
            make.width.height.equalTo(40)
        }
        
        // 3. Самолётик накрывает стрелку
        sendButton.snp.makeConstraints { make in
            make.edges.equalTo(arrowDownButton)
        }
        
        // 4. Текстовое поле — главный драйвер высоты.
        // Центрирует по своей линии кнопки и распирает верх/низ панели.
        textView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(arrowDownButton.snp.leading).offset(-12)
            make.top.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-12) // Тянет нижний край панели за собой
            make.height.greaterThanOrEqualTo(Constants.minTextViewHeight)// Одна строка
            make.height.lessThanOrEqualTo(Constants.maxTextViewHeight)// Максимум 3 строки
        }
        
        // Привязываем кнопки к центру базовой высоты текстового поля на старте
        microphoneButton.snp.makeConstraints { make in
            make.centerY.equalTo(textView.snp.centerY)
        }
        
        // 5. Плейсхолдер ложится ровно в начало текста
        placeholderLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().offset(10)
        }
    }
    
    private func setupActions() {
        textView.delegate = self
        arrowDownButton.addTarget(self, action: #selector(arrowButtonTapped), for: .touchUpInside)
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Public State Management
    func updateUI(for state: State, animated: Bool = true) {
        currentState = state
        
        switch state {
        case .normal:
            self.placeholderLabel.text = "How can I help you?"
        case .editingEmpty, .editingWithText:
            self.placeholderLabel.text = "Ask anything..."
        }
        
        // Управляем видимостью плейсхолдера
        self.placeholderLabel.isHidden = !textView.text.isEmpty
        
        let block = { [weak self] in
            guard let self = self else { return }
            
            switch state {
            case .normal:
                self.microphoneButton.alpha = 1.0
                self.arrowDownButton.alpha = 1.0
                self.sendButton.alpha = 0.0
                self.arrowTrailingConstraint?.update(offset: -12)
                
            case .editingEmpty:
                self.microphoneButton.alpha = 0.0
                self.arrowDownButton.alpha = 1.0
                self.sendButton.alpha = 0.0
                self.arrowTrailingConstraint?.update(offset: 52)
                
            case .editingWithText:
                self.microphoneButton.alpha = 0.0
                self.arrowDownButton.alpha = 0.0
                self.sendButton.alpha = 1.0
                self.arrowTrailingConstraint?.update(offset: 52)
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
    
    // MARK: - Handlers
    @objc private func arrowButtonTapped() {
        onArrowTapped?()
    }
    
    @objc private func sendButtonTapped() {
        guard let text = textView.text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        onSendTapped?(text)
        textView.text = ""
        updateUI(for: .editingEmpty) // Сбрасываем в пустое редактирование
    }
}

// MARK: - UITextViewDelegate
extension ChatInputView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let isTextEmpty = textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        updateUI(for: isTextEmpty ? .editingEmpty : .editingWithText)
        
        // Динамически включаем скролл, если текст перерос максимальную высоту
        let size = textView.sizeThatFits(CGSize(width: textView.frame.width, height: .infinity))
        textView.isScrollEnabled = size.height >= Constants.maxTextViewHeight
        
        // Магия для плавного роста панели ввода в iOS: заставляем родительское view обновить разметку
        if let superview = self.superview {
            UIView.animate(withDuration: 0.1) {
                superview.layoutIfNeeded()
            }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        let isTextEmpty = textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        updateUI(for: isTextEmpty ? .editingEmpty : .editingWithText)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        let isTextEmpty = textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        updateUI(for: isTextEmpty ? .normal : .editingWithText)
    }
}
