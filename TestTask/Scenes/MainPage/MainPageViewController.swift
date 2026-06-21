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
    
    // MARK: - UI Components
    private let backgroundView = GradientBackgroundView()
    
    private let settingsButton: UIButton = {
        let button = UIButton(type: .system)
        if let image = AppIcons.MainPage.settings {
            button.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
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
    }
    
    private func setupActions() {
        settingsButton.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
        askButton.addTarget(self, action: #selector(askButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func settingsButtonTapped() {
        router.trigger(.settings)
    }
    
    @objc private func askButtonTapped() {
        print("Нажали на плашку чата!")
    }
}
