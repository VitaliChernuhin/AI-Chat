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
    private let chatContainerView: UIView = UIView()
    
    lazy private var welcomeView: ChatWelcomeView = {
        let fullText = "Your AI assistant for anything"
        
        let gradientColors = [
            UIColor(red: 0.55, green: 0.60, blue: 0.90, alpha: 1.0),
            UIColor(red: 0.77, green: 0.35, blue: 0.52, alpha: 1.0)
        ]
        
        let gradientColor = UIColor.textGradient(from: gradientColors, size: CGSize(width: 220, height: 24))
        
        let attributedString = NSMutableAttributedString(
            string: fullText,
            attributes: [
                .foregroundColor: AppColors.accent,
                .font: FontFamily.Inter.semiBold(size: 20)
            ]
        )
        
        if let range = fullText.range(of: "AI assistant") {
            let nsRange = NSRange(range, in: fullText)
            attributedString.addAttribute(.foregroundColor, value: gradientColor, range: nsRange)
        }
        
        return ChatWelcomeView(
            attributedTitle: attributedString,
            subtitle: "Ask questions, get answers, and explore ideas\nin seconds"
        )
    }()
    
    private let inputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColors.chatAskAnythingBackground
        view.layer.cornerRadius = 24
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()
    
    private let inputBarView = ChatInputView()
    
    // MARK: - Screen States
    enum ChatScreenState {
        /// Чистый экран (история пуста, пользователь еще ничего не напечатал)
        case emptyInitial
        /// Начат ввод текста (сообщений еще нет, но в поле появилась хотя бы одна буква)
        case typingEmptyChat
        /// В чате есть контент (появилось хотя бы одно сообщение — экран приветствия скрыт навсегда)
        case hasMessages
    }
    
    private var currentScreenState: ChatScreenState = .emptyInitial {
        didSet {
            updateWelcomeViewVisibility(animated: true)
        }
    }
    
    // MARK: - Init
    init(router: WeakRouter<MainRoute>) {
        super.init(
            title: "AI Chat",
            subtitle: Date().dotFormattedString,
            avatarImage: AppIcons.NavigationBar.chatAvatar,
            rightImage: AppIcons.NavigationBar.history,
            router: router
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        // Обязательно вычищаем уведомления при уходе с экрана
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        setupActions()
        setupKeyboardObservers() // Запускаем слежку за клавиатурой
    }
    
    // MARK: - Setup
    private func setupViews() {
        view.backgroundColor = AppColors.background
        
        // Добавляем верхнюю рабочую область
        view.addSubview(chatContainerView)
        chatContainerView.addSubview(welcomeView)
        
        view.addSubview(inputBarView)
    }
    
    private func setupConstraints() {
        // 1. Панель ввода: высоты нет, она сама растягивается изнутри
        inputBarView.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
        
        // 2. Контейнер чата: его низ автоматически поджимается, когда растет панель ввода
        chatContainerView.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(inputBarView.snp.top)
        }
        
        // 3. WelcomeView: привязываем К К CONTAINER VIEW чата, а не к экрану или шторке!
        welcomeView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(23)
            
            // В идеале на больших экранах держим отступ 135pt от низа NavBar
            make.top.equalTo(navigationBar.snp.bottom).offset(135).priority(.low)
            
            // На iPhone SE жестко требуем отступ до НИЗА КОНТЕЙНЕРА ЧАТА (то есть до шторки) минимум 40pt
            // Используем chatContainerView.snp.bottom вместо inputBarView.snp.top
            make.bottom.lessThanOrEqualTo(chatContainerView.snp.bottom).offset(-40).priority(.required)
        }
    }
    
    private func setupActions() {
        // Подписываемся на изменения состояний нашей умной шторки
        inputBarView.onStateChanged = { [weak self] inputState in
            guard let self = self else { return }
            
            // Если в чате уже есть сообщения, WelcomeView скрыт навсегда, выходим
            if self.currentScreenState == .hasMessages { return }
            
            switch inputState {
            case .normal, .editingEmpty:
                // Текст пустой или клавиатуру свернули -> плавно возвращаем WelcomeView
                self.currentScreenState = .emptyInitial
            case .editingWithText:
                // Появилась хотя бы одна буква -> плавно скрываем WelcomeView
                self.currentScreenState = .typingEmptyChat
            }
        }
        
        inputBarView.onArrowTapped = { [weak self] in
            self?.view.endEditing(true)
        }
        
        inputBarView.onSendTapped = { [weak self] text in
            print("Отправка: \(text)")
            // Как только отправили первое сообщение — переключаем стейт в контентный режим
            self?.currentScreenState = .hasMessages
        }
    }
}

// MARK: - Keyboard Management (Private)
private extension AIChatViewController {
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardNotification),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardNotification),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc func handleKeyboardNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curveRaw = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else { return }
        
        let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
        let keyboardHeight = keyboardFrame.cgRectValue.height
        
        inputBarView.snp.remakeConstraints { make in
            if isKeyboardShowing {
                // Привязываемся к самому низу ЭКРАНА, вычитая высоту клавиатуры
                make.bottom.equalToSuperview().offset(-keyboardHeight)
            } else {
                // Возвращаем привязку к Safe Area, когда клавиатура скрыта
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            }
            make.leading.trailing.equalToSuperview()
        }
        
        let animationOptions = UIView.AnimationOptions(rawValue: curveRaw << 16)
        UIView.animate(withDuration: duration, delay: 0, options: animationOptions, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - Update welcome view visibility (private)
private extension AIChatViewController {
    
    func updateWelcomeViewVisibility(animated: Bool) {
        let targetAlpha: CGFloat = currentScreenState == .emptyInitial ? 1.0 : 0.0
        
        // Защита: если альфа уже совпадает, не гоняем анимационный движок вхолостую
        guard welcomeView.alpha != targetAlpha else { return }
        
        // Используем guard let внутри замыкания, чтобы тип стал строго () -> Void
        let block = { [weak self] in
            guard let self = self else { return }
            self.welcomeView.alpha = targetAlpha
        }
        
        if animated {
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: block)
        } else {
            block()
        }
    }
}
