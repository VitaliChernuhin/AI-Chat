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
    private let chatContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        return view
    }()
    
    private let welcomeStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        return stack
    }()
    
    private let welcomeTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppColors.accent
        label.font = FontFamily.Inter.semiBold(size: 20)
        label.textAlignment = .center
        label.numberOfLines = 2
        
        let text = "Your AI assistant for anything"
        let attributedString = NSMutableAttributedString(string: text)
        if let range = text.range(of: "AI assistant") {
            let nsRange = NSRange(range, in: text)
            attributedString.addAttribute(.foregroundColor, value: UIColor(red: 0.77, green: 0.35, blue: 0.52, alpha: 1.0), range: nsRange)
        }
        label.attributedText = attributedString
        return label
    }()
    
    private let inputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColors.chatAskAnythingBackground
        view.layer.cornerRadius = 24
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()
    
    private let inputBarView = ChatInputView()
    
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
        chatContainerView.addSubview(welcomeStackView)
        welcomeStackView.addArrangedSubview(welcomeTitleLabel)
        
        // Добавляем готовую панель ввода
        view.addSubview(inputBarView)
    }
    
    private func setupConstraints() {
        inputBarView.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom) // Ровно на безопасную зону
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(88.0) // Фиксированная высота по дизайну
        }
        
        chatContainerView.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom) // Изменено с .top на .bottom
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(inputBarView.snp.top)
        }
        
        welcomeStackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(32)
        }
    }
    
    private func setupActions() {
        // Чистим этот блок! Оставляем только базовое уведомление, если нужно
        inputBarView.onStateChanged = nil
        
        inputBarView.onArrowTapped = { [weak self] in
            self?.view.endEditing(true)
        }
        
        inputBarView.onSendTapped = { [weak self] text in
            print("Отправка: \(text)")
        }
    }
    
    private func setupKeyboardObservers() {
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
    
    @objc private func handleKeyboardNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curveRaw = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else { return }
        
        let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
        let keyboardHeight = keyboardFrame.cgRectValue.height
        
        inputBarView.snp.remakeConstraints { make in
            if isKeyboardShowing {
                // Когда клавиатура открыта — привязываемся к самому низу ЭКРАНА,
                // вычитая высоту клавиатуры
                make.bottom.equalToSuperview().offset(-keyboardHeight)
            } else {
                // Когда клавиатура скрыта — возвращаем привязку к Safe Area,
                // чтобы панель стояла на месте и не падала вниз
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            }
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(88.0)
        }
        
        let animationOptions = UIView.AnimationOptions(rawValue: curveRaw << 16)
        UIView.animate(withDuration: duration, delay: 0, options: animationOptions, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
