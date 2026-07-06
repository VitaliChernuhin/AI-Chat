//
//  AIChatsHistoryViewController.swift
//  TestTask
//
//  Created by Vit Chernuhin on 06.07.2026.
//

import UIKit
import SnapKit
import Combine

final class AIChatsHistoryViewController: BaseViewController {
    
    // MARK: - UI Components
    private let placeholderView = ChatsHistoryPlaceholderView(
            title: "No chats yet",
            subtitle: "Start a conversation to see\n your history here"
    )
    
    // Сетка коллекции для вывода карточек истории по секциям
    private lazy var historyCollectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: createCompositionalLayout())
        cv.backgroundColor = .clear
        cv.isHidden = true // Скрыта, пока нет контента
        return cv
    }()
    
    // MARK: - Properties
    private let viewModel: AIChatsHistoryViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init(viewModel: AIChatsHistoryViewModel) {
        self.viewModel = viewModel
        super.init(title: "AI Chat History")
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
        
        bindViewModel()
 
        viewModel.handleViewEvent(.viewDidLoad)
    }
}

// MARK: - Setup views (private)
private extension AIChatsHistoryViewController {
    func setupViews() {
        view.backgroundColor = AppColors.background
        
        view.addSubview(placeholderView)
        view.addSubview(historyCollectionView)
    }
}

// MARK: - Setup constraints (private)
private extension AIChatsHistoryViewController {
    func setupConstraints() {
      
        placeholderView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(23)
        }
        
        historyCollectionView.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom).offset(16)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

// MARK: - Setup actions (private)
private extension AIChatsHistoryViewController {
    func setupActions() {
        navigationBar.onBackTapped = { [weak self] in
            self?.viewModel.handleAction(.backTapped)
        }
    }
}

// MARK: - Bind ViewModel (private)
private extension AIChatsHistoryViewController {
    func bindViewModel() {
        // Слушаем стейт пустоты экрана от вью-модели
        viewModel.$isEmpty
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isHistoryEmpty in
                guard let self = self else { return }
                // Управляем видимостью слоев на экране
                self.placeholderView.isHidden = !isHistoryEmpty
                self.historyCollectionView.isHidden = isHistoryEmpty
            }
            .store(in: &cancellables)
    }
}

// MARK: - Compositional Layout (private)
private extension AIChatsHistoryViewController {
    func createCompositionalLayout() -> UICollectionViewLayout {
        // Лэйаут секций и карточек соберем чуть позже на основе ячейки
        return UICollectionViewFlowLayout()
    }
}
