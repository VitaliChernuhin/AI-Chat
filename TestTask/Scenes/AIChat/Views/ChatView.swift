//
//  ChatView.swift
//  TestTask
//
//  Created by Vit Chernuhin on 26.06.2026.
//

import UIKit
import SnapKit

final class ChatView: UIView {
    
    // MARK: - Properties
    var currentScreenState: ChatScreenState = .emptyInitial {
        didSet {
            updateWelcomeViewVisibility(animated: true)
        }
    }
    
    // MARK: - UI Components
    private(set) lazy var collectionView: UICollectionView = {
        let layout = createCompositionalLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.alwaysBounceVertical = true
        cv.showsVerticalScrollIndicator = false
        cv.register(ChatUserCell.self, forCellWithReuseIdentifier: ChatUserCell.reuseIdentifier)
        cv.register(ChatTypingIndicatorCell.self, forCellWithReuseIdentifier: ChatTypingIndicatorCell.reuseIdentifier)
        cv.register(ChatAICell.self, forCellWithReuseIdentifier: ChatAICell.reuseIdentifier)
        return cv
    }()
    
    // Сюда мы бережно переносим welcomeView из контроллера!
    private lazy var welcomeView: ChatWelcomeView = {
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
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupViews() {
        backgroundColor = .clear
        addSubview(collectionView)
        addSubview(welcomeView) // Добавляем заглушку внутрь единого контейнера чата
    }
    
    private func setupConstraints() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        welcomeView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(23)
            
            // В идеале держим отступ 135pt от верха ChatView
            make.top.equalToSuperview().offset(135).priority(.low)
            
            make.bottom.lessThanOrEqualTo(snp.bottom).offset(-40).priority(.required)
        }
    }
}

// MARK: - Reload and scroll to bottom (public)
extension ChatView {
    
    /// Полностью обновляет ленту чата и автоматически скроллит её к последнему сообщению
    func reloadAndScrollToBottom(animated: Bool = true) {
        collectionView.reloadData()
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let totalItems = self.collectionView.numberOfItems(inSection: 0)
            guard totalItems > 0 else { return }
            
            let indexPath = IndexPath(item: totalItems - 1, section: 0)
            self.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: animated)
        }
    }
    
    func scrollToBottom(animated: Bool = true) {
        let lastItem = collectionView.numberOfItems(inSection: 0) - 1
        guard lastItem >= 0 else { return }
        
        let indexPath = IndexPath(item: lastItem, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: animated)
    }
}

// MARK: - Update welcome view visibility (private)
private extension ChatView {
    
    func updateWelcomeViewVisibility(animated: Bool) {
        let targetAlpha: CGFloat = currentScreenState == .emptyInitial ? 1.0 : 0.0
        
        guard welcomeView.alpha != targetAlpha else { return }

        let block: () -> Void = { [weak self] in
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

// MARK: - Compositional Layout
private extension ChatView {
    
    func createCompositionalLayout() -> UICollectionViewLayout {

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(60)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        item.edgeSpacing = NSCollectionLayoutEdgeSpacing(
            leading: nil,
            top: .fixed(24),
            trailing: nil,
            bottom: nil
        )
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(60)
        )
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}
