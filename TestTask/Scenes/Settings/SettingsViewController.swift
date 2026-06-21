//
//  SettingsViewController.swift
//  TestTask
//
//  Created by Vit Chernuhin on 21.06.2026.
//

import UIKit
import SnapKit

final class SettingsViewController: UIViewController {
    
    // Переиспользуем наш идеальный кастомный фон
    private let backgroundView = BackgroundView()
    
    private let comingSoonLabel: UILabel = {
        let label = UILabel()
        label.text = "Settings\ncoming soon..."
        label.textColor = AppColors.accent
        label.font = FontFamily.Inter.bold(size: 32)
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        view.addSubview(backgroundView)
        view.addSubview(comingSoonLabel)
    }
    
    private func setupConstraints() {
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        comingSoonLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(40)
        }
    }
}

