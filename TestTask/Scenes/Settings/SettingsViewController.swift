//
//  SettingsViewController.swift
//  TestTask
//
//  Created by Vit Chernuhin on 21.06.2026.
//

import UIKit
import SnapKit
import XCoordinator

final class SettingsViewController: BaseViewController, Routable, NavigationBarOwner{
    
    internal let router: WeakRouter<MainRoute>
    
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
    
    // MARK: Life cycle
    init(router: WeakRouter<MainRoute>) {
        self.router = router
        super.init(
            title: "Settings",
            subtitle: nil,
            avatarImage: nil,
            rightImage: nil
        )
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUniqueViews()
        setupUniqueConstraints()
        setupAutomaticBackNavigation()
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


