//
//  SettingsViewController.swift
//  TestTask
//
//  Created by Vit Chernuhin on 21.06.2026.
//

import UIKit
import SnapKit

final class SettingsViewController: BaseViewController<MainRoute> {
    
    // MARK: - UI Components
    private let comingSoonLabel: UILabel = {
        let label = UILabel()
        label.text = "Settings\ncoming soon..."
        label.textColor = AppColors.accent
        label.font = FontFamily.Inter.bold(size: 32)
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUniqueViews()
        setupUniqueConstraints()
    }
    
    // MARK: - Setup Unique Content
    private func setupUniqueViews() {
        view.addSubview(comingSoonLabel)
    }
    
    private func setupUniqueConstraints() {
        comingSoonLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(40)
        }
    }
}


