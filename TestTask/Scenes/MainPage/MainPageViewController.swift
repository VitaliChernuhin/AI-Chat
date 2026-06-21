//
//  MainPageViewController.swift
//  TestTask
//
//  Created by Vit Chernuhin on 20.06.2026.
//

import UIKit
import SnapKit

final class MainPageViewController: UIViewController {
    
    // MARK: - UI Components
    private let backgroundView = BackgroundView()
    
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
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
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
}
