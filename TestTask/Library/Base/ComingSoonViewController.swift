//
//  ComingSoonViewController.swift
//  TestTask
//
//  Created by Vit Chernuhin on 21.06.2026.
//

import UIKit
import SnapKit
import XCoordinator

final class ComingSoonViewController: BaseViewController, Routable, NavigationBarOwner {
    
    internal let router: WeakRouter<MainRoute>
    
    private var navTitle: String?
    
    // MARK: - UI Components
    private lazy var comingSoonLabel: UILabel = {
        let label = UILabel()
        label.text = "\(navTitle ?? "Feature")\ncoming soon..."
        label.textColor = AppColors.accent
        label.font = FontFamily.Inter.bold(size: 32)
        label.textAlignment = .center
        label.numberOfLines = 3
        return label
    }()
    
    // MARK: Life cycle
    init(router: WeakRouter<MainRoute>, title: String) {
        self.router = router
        self.navTitle = title
        super.init(
            title: title,
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


