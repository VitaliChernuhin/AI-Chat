//
//  AIChatViewController.swift
//  TestTask
//
//  Created by Vit Chernuhin on 22.06.2026.
//

import UIKit
import SnapKit
import XCoordinator


final class AIChatViewController: BaseViewController<MainRoute> {
    
    
    // MARK: - UI Components
    
    // Большой приветственный заголовок
    private let welcomeTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppColors.accent
        label.font = FontFamily.Inter.bold(size: 22)
        label.textAlignment = .center
        label.numberOfLines = 2
        
        let text = "Your AI assistant for anything"
        let attributedString = NSMutableAttributedString(string: text)
        if let range = text.range(of: "AI assistant") {
            let nsRange = NSRange(range, in: text)
            // Розово-фиолетовый акцент на фразу из Bento-градиента
            attributedString.addAttribute(.foregroundColor, value: UIColor(red: 0.77, green: 0.35, blue: 0.52, alpha: 1.0), range: nsRange)
        }
        label.attributedText = attributedString
        return label
    }()
    
    // Подзаголовок приветствия
    private let welcomeSubtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Ask questions, get answers, and explore ideas\nin seconds"
        label.textColor = AppColors.navBarSubtitle // Твой мягкий серый цвет
        label.font = FontFamily.Inter.regular(size: 14)
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    // Нижняя плашка ввода
    private let inputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColors.askAnyBackground
        view.layer.cornerRadius = 24
        return view
    }()
    
    private let textField: UITextField = {
        let field = UITextField()
        // Применяем твой новый подогнанный темный цвет плейсхолдера (89, 86, 91) 🌟
        field.attributedPlaceholder = NSAttributedString(
            string: "Ask anything...",
            attributes: [NSAttributedString.Key.foregroundColor: AppColors.placeholderText]
        )
        field.textColor = AppColors.accent
        field.font = FontFamily.Inter.regular(size: 15)
        return field
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.up.circle.fill"), for: .normal)
        button.tintColor = AppColors.accent.withAlphaComponent(0.6)
        return button
    }()
    
    // MARK: - Init
    init(router: WeakRouter<MainRoute>) {
        super.init(
            title: "AI Chat",
            subtitle: "26.03.2026",
            avatarImage: AppIcons.NavigationBar.chatAvatar,
            rightImage: AppIcons.NavigationBar.history,
            router: router
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        setupActions()
        setupKeyboardObservers()
    }
    
    // MARK: - Setup
    private func setupViews() {
        // Базовый фоновый цвет страницы (10, 7, 14)
        view.backgroundColor = AppColors.background
        
        view.addSubview(navigationBar)
        view.addSubview(welcomeTitleLabel)
        view.addSubview(welcomeSubtitleLabel)
        view.addSubview(inputContainerView)
        
        inputContainerView.addSubview(textField)
        inputContainerView.addSubview(sendButton)
    }
    
    private func setupConstraints() {
        
        // Поле ввода крепим к нижней границе safeArea
        inputContainerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
            make.height.equalTo(52)
        }
        
        // Центрированный контент держим на красивом расстоянии над инпутом
        welcomeSubtitleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(inputContainerView.snp.top).offset(-180)
            make.leading.trailing.equalToSuperview().inset(32)
        }
        
        welcomeTitleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(welcomeSubtitleLabel.snp.top).offset(-12)
            make.leading.trailing.equalToSuperview().inset(32)
        }
        
        textField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.trailing.equalTo(sendButton.snp.leading).offset(-8)
        }
        
        sendButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(32)
        }
    }
    
    private func setupActions() {
        // Закрытие клавиатуры по тапу на любое свободное место экрана
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Keyboard Animation
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardHeight = keyboardFrame.cgRectValue.height
        
        inputContainerView.snp.updateConstraints { make in
        // Поднимаем инпут на высоту клавиатуры за вычетом отступа безопасной зоны
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-keyboardHeight + 34)
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        inputContainerView.snp.updateConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
