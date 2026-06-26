//
//  AIChatViewController.swift
//  TestTask
//
//  Created by Vit Chernuhin on 22.06.2026.
//

import UIKit
import SnapKit
import XCoordinator
import Combine

final class AIChatViewController: BaseViewController {
    
    // MARK: - UI Components
    
    private let chatView: ChatView = ChatView()
    private let inputBarView = ChatInputView()
    
    // MARK: - Properties
    private let viewModel: AIChatViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init(viewModel: AIChatViewModel) {
        self.viewModel = viewModel
        super.init(
            title: "AI Chat",
            subtitle: Date().dotFormattedString,
            avatarImage: AppIcons.NavigationBar.chatAvatar,
            rightImage: AppIcons.NavigationBar.history,
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
        bindViewModel()
    }
    
    // MARK: - Setup
    private func setupViews() {
        view.backgroundColor = AppColors.background
        
        view.addSubview(chatView)
        view.addSubview(inputBarView)
        
        chatView.collectionView.dataSource = self
        chatView.collectionView.delegate = self
    }
    
    private func setupConstraints() {
        //Панель ввода: высоты нет, она сама растягивается изнутри
        inputBarView.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
        chatView.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(inputBarView.snp.top)
        }
    }
    
    private func setupActions() {
        inputBarView.onStateChanged = { [weak self] inputState in
            guard let self = self else { return }
            
            switch inputState {
            case .normal, .editingEmpty:
                // Текст пустой или клавиатуру свернули -> передаем во ViewModel
                self.viewModel.changeInputState(hasText: false)
            case .editingWithText:
                // Появилась хотя бы одна буква -> передаем во ViewModel
                self.viewModel.changeInputState(hasText: true)
            }
        }
        
        inputBarView.onArrowTapped = { [weak self] in
            self?.view.endEditing(true)
        }
        
        inputBarView.onSendTapped = { [weak self] text in
            // Передаем отправку текста во вью-модель
            self?.viewModel.sendMessage(text)
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

// MARK: - ViewModel Binding (Private)
private extension AIChatViewController {
    
    func bindViewModel() {
        viewModel.$screenState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self = self else { return }
                self.chatView.currentScreenState = state
            }
            .store(in: &cancellables)
        
        // 2. Слушаем обновление массива сообщений для коллекции
        viewModel.$messages
            .receive(on: DispatchQueue.main)
            .sink { [weak self] messages in
                guard let self = self else { return }
                self.chatView.reloadAndScrollToBottom(animated: true)
            }
            .store(in: &cancellables)
        
        // 3. Слушаем индикатор набора текста AI
        viewModel.$isAISpeaking
            .receive(on: DispatchQueue.main)
            .sink { isSpeaking in
                print("Анимация трех точек: \(isSpeaking)")
            }
            .store(in: &cancellables)
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate
extension AIChatViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Если ИИ печатает, искусственно увеличиваем количество ячеек на одну (для индикатора)
        let messagesCount = viewModel.messages.count
        return viewModel.isAISpeaking ? messagesCount + 1 : messagesCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if viewModel.isAISpeaking && indexPath.item == viewModel.messages.count {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ChatTypingIndicatorCell.reuseIdentifier,
                for: indexPath
            ) as? ChatTypingIndicatorCell else {
                return UICollectionViewCell()
            }
            
            cell.startAnimating()
            cell.backgroundColor = .clear
            return cell
        }
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ChatUserCell.reuseIdentifier,
            for: indexPath
        ) as? ChatUserCell else {
            return UICollectionViewCell()
        }
        
        let message = viewModel.messages[indexPath.item]
        cell.configure(with: message)
        cell.backgroundColor = .clear
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

        if let typingCell = cell as? ChatTypingIndicatorCell {
            typingCell.startAnimating()
        }
    }
}


