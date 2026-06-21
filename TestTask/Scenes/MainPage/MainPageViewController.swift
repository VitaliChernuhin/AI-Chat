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
    }
    
    private func setupActions() {
        settingsButton.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func settingsButtonTapped() {
        router.trigger(.settings)
    }
}
