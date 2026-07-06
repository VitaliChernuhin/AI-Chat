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
    private var sectionKeys: [String] = []
    private var chatSections: [String: [ChatHistoryItem]] = [:]
    
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
        
        historyCollectionView.register(ChatHistoryCell.self, forCellWithReuseIdentifier: ChatHistoryCell.reuseIdentifier)
        historyCollectionView.register(
            ChatHistorySectionHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: ChatHistorySectionHeader.reuseIdentifier
        )
        
        historyCollectionView.dataSource = self
        historyCollectionView.delegate = self
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
            make.top.equalTo(navigationBar.snp.bottom).offset(24)
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
        
        viewModel.$isEmpty
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isHistoryEmpty in
                guard let self = self else { return }
                self.placeholderView.isHidden = !isHistoryEmpty
                self.historyCollectionView.isHidden = isHistoryEmpty
            }
            .store(in: &cancellables)
            
        viewModel.$chatSections
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sections in
                guard let self = self else { return }
                self.chatSections = sections
                self.sectionKeys = sections.keys.sorted { k1, k2 in
                    if k1 == "Today" { return true }
                    if k2 == "Today" { return false }
                    if k1 == "Yesterday" { return true }
                    if k2 == "Yesterday" { return false }
                    return k1 > k2
                }
                self.historyCollectionView.reloadData()
            }
            .store(in: &cancellables)
    }
}

// MARK: - Compositional Layout (private)
private extension AIChatsHistoryViewController {
    func createCompositionalLayout() -> UICollectionViewLayout {
        
        // 1. Одиночная ячейка карточки диалога
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Делаем зазор 12pt строго СНИЗУ каждой карточки, чтобы они не слипались
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 12, trailing: 0)
        
        // 2. Вертикальная группа (Чистая высота карточки 72pt из Figma + зазор 12pt = 84pt)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(84)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        // 3. Секция
        let section = NSCollectionLayoutSection(group: group)
        
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 0, trailing: 16)
        
        // 4. Настраиваем размеры и тип хедера секции
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(32) // Высота хедера сама подстроится под шрифт Inter SemiBold 20
        )
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [sectionHeader]
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate
extension AIChatsHistoryViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sectionKeys.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let key = sectionKeys[section]
        return chatSections[key]?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ChatHistoryCell.reuseIdentifier,
            for: indexPath
        ) as? ChatHistoryCell else {
            return UICollectionViewCell()
        }
        
        let key = sectionKeys[indexPath.section]
        if let item = chatSections[key]?[indexPath.item] {
            cell.configure(text: item.text, time: item.time)
        }
        return cell
    }
    
    // Отрисовка наших кастомных заголовков дат (Today, Yesterday)
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: ChatHistorySectionHeader.reuseIdentifier,
                for: indexPath
              ) as? ChatHistorySectionHeader else {
            return UICollectionReusableView()
        }
        
        let key = sectionKeys[indexPath.section]
        header.configure(title: key)
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let key = sectionKeys[indexPath.section]
        if let item = chatSections[key]?[indexPath.item] {
            // Передаем экшен выбора чата во вью-модель!
            viewModel.handleAction(.chatSelected(id: item.id))
        }
    }
}


