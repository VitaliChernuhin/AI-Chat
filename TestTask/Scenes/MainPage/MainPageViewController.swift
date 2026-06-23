//
//  MainPageViewController.swift
//  TestTask
//
//  Created by Vit Chernuhin on 20.06.2026.
//

import UIKit
import SnapKit
import XCoordinator

final class MainPageViewController: UIViewController {
    
    // MARK: - Properties
    private let router: WeakRouter<MainRoute>
    
    private let features: [FeatureItem] = [
        FeatureItem(type: .turnPhotoToVideo),
        FeatureItem(type: .fixWriting),
        FeatureItem(type: .summarize)
    ]
    
    // MARK: - UI Components
    private let backgroundView = GradientBackgroundView()
    
    private let settingsButton: UIButton = {
        let button = UIButton(type: .system)
        if let image = AppIcons.MainPage.settings {
            button
                .setImage(
                    image.withRenderingMode(.alwaysTemplate),
                    for: .normal
                )
        }
        button.tintColor = AppColors.settingsIcon
        button.backgroundColor = AppColors.card
        return button
    }()
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = AppIcons.MainPage.logo
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let mainTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Your AI tools,\nready to go"
        label.textColor = AppColors.accent
        label.font = FontFamily.Inter.bold(size: 28)
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    private let askButton = AskAnyButton(type: .system)
    
    private lazy var collectionView: UICollectionView = {
        let layout = createCompositionalLayout()
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isScrollEnabled = false
        
        collectionView
            .register(
                FeatureCell.self,
                forCellWithReuseIdentifier: FeatureCell.reuseIdentifier
            )
        return collectionView
    }()
    
    
    // MARK: - Init
    init(router: WeakRouter<MainRoute>) {
        self.router = router
        super.init(nibName: nil, bundle: nil)
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
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        settingsButton.layer.cornerRadius = settingsButton.bounds.width / 2
    }
    
    // MARK: - Setup
    private func setupViews() {
        view.addSubview(backgroundView)
        view.addSubview(settingsButton)
        view.addSubview(logoImageView)
        view.addSubview(mainTitleLabel)
        view.addSubview(askButton)
        view.addSubview(collectionView)
    }
    
    private func setupConstraints() {
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        settingsButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.width.height.equalTo(40)
        }
        
        logoImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(80)
            make.width.height.equalTo(60)
        }
        
        mainTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(32)
        }
        
        askButton.snp.makeConstraints { make in
            make.top.equalTo(mainTitleLabel.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(56)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(askButton.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-10)
        }
    }
    
    private func setupActions() {
        settingsButton
            .addTarget(
                self,
                action: #selector(settingsButtonTapped),
                for: .touchUpInside
            )
        askButton
            .addTarget(
                self,
                action: #selector(askButtonTapped),
                for: .touchUpInside
            )
    }
    
    // MARK: - Actions
    @objc private func settingsButtonTapped() {
        router.trigger(.settings)
    }
    
    @objc private func askButtonTapped() {
        router.trigger(.aiChat)
    }
}

// MARK: - Composition layout
extension MainPageViewController {
    
    // MARK: - Compositional Layout Magic 🌟
    private func createCompositionalLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { _, _ in
            
            let screenHeight = UIScreen.main.bounds.height
            let bentoGridHeight: CGFloat = screenHeight <= 667 ? 255 : 335
            
            // 1. ЛЕВАЯ КАРТОЧКА
            let leftItem = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                                   heightDimension: .fractionalHeight(1.0))
            )
            leftItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 4)
            
            // 2. ПРАВЫЕ КАРТОЧКИ
            let rightItem = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .fractionalHeight(0.5))
            )
            rightItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 0)
            
            // Вертикальная группа для правой колонки
            let rightGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                                   heightDimension: .fractionalHeight(1.0)),
                subitems: [rightItem]
            )
            
            rightGroup.interItemSpacing = .fixed(8)
            
            // 3. ГЛАВНАЯ ГРУППА СЕТКИ
            let mainGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .absolute(bentoGridHeight)),
                subitems: [leftItem, rightGroup]
            )
            
            let section = NSCollectionLayoutSection(group: mainGroup)
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 20, trailing: 16)
            
            return section
        }
    }
}

// MARK: - UICollectionView Data Source & Delegate
extension MainPageViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return features.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeatureCell.reuseIdentifier, for: indexPath) as? FeatureCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: features[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath ) {
        let selectedItem = features[indexPath.item]
        print("Нажали на карточку Bento: \(selectedItem.title)")
    }
}
