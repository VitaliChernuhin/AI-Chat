//
//  PaywallViewController.swift
//  TestTask
//
//  Created by Vit Chernuhin on 01.07.2026.
//

import UIKit
import SnapKit
import Combine

final class PaywallViewController: UIViewController {
    
    // MARK: - UI Components
    private let backgroundView = GradientBackgroundView()
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(AppIcons.Paywall.close, for: .normal)
        button.tintColor = AppColors.paywallCloseButton
        button.alpha = 0.0
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Create anything\nyou want"
        label.textColor = .white
        label.font = FontFamily.Inter.bold(size: 34)
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    private let featuresStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }()
    
    private lazy var productCollectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: createCompositionalLayout())
        cv.backgroundColor = .clear
        cv.isScrollEnabled = false // Всего 2 элемента, скролл выключаем
        cv.dataSource = self
        cv.delegate = self
        cv.register(PaywallProductCell.self, forCellWithReuseIdentifier: PaywallProductCell.reuseIdentifier)
        return cv
    }()
    
    private let unlockButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Unlock now", for: .normal)
        button.setTitleColor(AppColors.accent, for: .normal)
        button.titleLabel?.font = FontFamily.Inter.semiBold(size: 16)
        button.layer.cornerRadius = 24
        button.clipsToBounds = true
        return button
    }()
    
    private let cancelAnytimeView = PaywallCancelAnytimeView()
    
    // Стек для ссылок в подвале экрана
    private let footerStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fill
        return stack
    }()
    
    // MARK: - Properties
    private let viewModel: PaywallViewModel
    
    private let unlockGradientLayer = CAGradientLayer()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init(viewModel: PaywallViewModel) {
        self.viewModel = viewModel
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
        buildFeaturesList()
        
        bindViewModel()
        viewModel.handleViewEvent(.viewDidLoad)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        unlockGradientLayer.frame = unlockButton.bounds
    }
}

// MARK: Setup views
private extension PaywallViewController {
    func setupViews() {
        view.addSubview(backgroundView)
        view.addSubview(closeButton)
        view.addSubview(titleLabel)
        view.addSubview(featuresStackView)
        view.addSubview(productCollectionView)
        view.addSubview(cancelAnytimeView)
        view.addSubview(unlockButton)
        view.addSubview(footerStackView)
        setupUnlockGradientLayer()
        setupFooter()
    }
    
    func setupFooter() {
        let privacyButton = createFooterButton(title: "Privacy Policy", alignment: .left, action: #selector(privacyTapped))
        let restoreButton = createFooterButton(title: "Restore", alignment: .center, action: #selector(restoreTapped))
        let termsButton = createFooterButton(title: "Terms of Use", alignment: .right, action: #selector(termsTapped))
        
        footerStackView.addArrangedSubview(privacyButton)
        footerStackView.addArrangedSubview(restoreButton)
        footerStackView.addArrangedSubview(termsButton)
    }
    
    func createFooterButton(title: String, alignment: UIControl.ContentHorizontalAlignment, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(AppColors.paywallPriceText, for: .normal)
        button.titleLabel?.font = FontFamily.Inter.regular(size: 11)
        
        // Жестко прижимаем текст внутри кнопки к нужному краю!
        button.contentHorizontalAlignment = alignment
        
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    func setupUnlockGradientLayer() {
        unlockGradientLayer.colors = [AppColors.brandGradientStart.cgColor, AppColors.brandGradientEnd.cgColor]
        unlockGradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        unlockGradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        unlockButton.layer.insertSublayer(unlockGradientLayer, at: 0)
    }
}

// MARK: - Setup constraints (private)
private extension PaywallViewController {
    func setupConstraints() {
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(44)
        }
        
        let isSmallScreen = UIDevice.isSmallScreen
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(isSmallScreen ? 60 : 147)
            make.leading.trailing.equalToSuperview().inset(53)
        }
        
        featuresStackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(isSmallScreen ? 12 : 32)
            make.leading.equalTo(titleLabel.snp.leading).offset(8.5)
            make.trailing.equalTo(titleLabel.snp.trailing).offset(-8.5)
        }
        
        productCollectionView.snp.makeConstraints { make in
            make.top.equalTo(featuresStackView.snp.bottom).offset(isSmallScreen ? 16 : 32)
            make.leading.trailing.equalToSuperview().inset(16)
            
            make.bottom.equalTo(cancelAnytimeView.snp.top).offset(isSmallScreen ? -8 : -16)
        }
        
        cancelAnytimeView.snp.makeConstraints { make in
            make.bottom.equalTo(unlockButton.snp.top)
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
        }
        
        unlockButton.snp.makeConstraints { make in
            make.bottom.equalTo(footerStackView.snp.top).offset(isSmallScreen ? -12 : -16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(50)
        }
        
        footerStackView.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(isSmallScreen ? -4 : -8)
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }
}

// MARK: - Setup actions (private)
private extension PaywallViewController {
    func setupActions() {
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        unlockButton.addTarget(self, action: #selector(unlockButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func closeButtonTapped() {
        viewModel.handleAction(.closeTapped)
    }
    
    @objc private func unlockButtonTapped() {
        viewModel.handleAction(.purchaseTapped)
    }
    
    @objc func privacyTapped() { print("Privacy Policy tapped") }
    @objc func restoreTapped() { print("Restore Purchases tapped") }
    @objc func termsTapped() { print("Terms of Use tapped") }
}

// MARK: - Build features list logic (private)
private extension PaywallViewController {
    
    struct PaywallFeatureItem {
        let icon: UIImage?
        let text: String
    }
    
    func buildFeaturesList() {
        let featureItems: [PaywallFeatureItem] = [
            PaywallFeatureItem(icon: AppIcons.Paywall.resultInSeconds, text: "Get results in seconds"),
            PaywallFeatureItem(icon: AppIcons.Paywall.turnAnyText, text: "Turn any text into better writing"),
            PaywallFeatureItem(icon: AppIcons.Paywall.simplifyComplexInformation, text: "Simplify complex information"),
            PaywallFeatureItem(icon: AppIcons.Paywall.createWithAITemplate, text: "Create content with AI templates")
        ]
        
        for item in featureItems {
            let rowView = UIView()
            
            let iconView = UIImageView()
            iconView.image = item.icon // Передаем честный ассет из Figma
            iconView.contentMode = .scaleAspectFit
            
            let textLabel = UILabel()
            textLabel.text = item.text
            textLabel.textColor = .white
            textLabel.font = FontFamily.Inter.medium(size: 16)
            textLabel.numberOfLines = 0
            textLabel.lineBreakMode = .byWordWrapping
            
            rowView.addSubview(iconView)
            rowView.addSubview(textLabel)
            
            iconView.snp.makeConstraints { make in
                make.leading.centerY.equalToSuperview()
                make.width.height.equalTo(24)
            }
            
            textLabel.snp.makeConstraints { make in
                make.leading.equalTo(iconView.snp.trailing).offset(8)
                make.trailing.top.bottom.equalToSuperview()
            }
            
            featuresStackView.addArrangedSubview(rowView)
        }
    }
}

// MARK: - Create composition layout (private)
private extension PaywallViewController {
    func createCompositionalLayout() -> UICollectionViewLayout {
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 12, trailing: 0)
        
        // Вертикальная группа (высота плашки 72pt + наш отступ 12pt = 84pt)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(84)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        // Секция
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .zero
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}

// MARK: - Bind ViewModel (private)
private extension PaywallViewController {
    func bindViewModel() {
        viewModel.$isCloseButtonVisible
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isVisible in
                self?.animateCloseButtonVisibility(isVisible: isVisible)
            }
            .store(in: &cancellables)
        
        viewModel.$uiModels
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.productCollectionView.reloadData()
            }
            .store(in: &cancellables)
    }
}

// MARK: - Close button visability (private)
private extension PaywallViewController {
    func animateCloseButtonVisibility(isVisible: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.closeButton.alpha = isVisible ? 1.0 : 0.0
        }
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate
extension PaywallViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.uiModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PaywallProductCell.reuseIdentifier,
            for: indexPath
        ) as? PaywallProductCell else {
            return UICollectionViewCell()
        }
        
        let model = viewModel.uiModels[indexPath.item]
        cell.configure(with: model)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let selectedModel = viewModel.uiModels[indexPath.item]
        viewModel.handleAction(.selectProduct(selectedModel.type))
    }
}
