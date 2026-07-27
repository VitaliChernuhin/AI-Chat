//
//  BaseViewController.swift
//  TestTask
//
//  Created by Vit Chernuhin on 21.06.2026.
//

import UIKit
import SnapKit

class BaseViewController: UIViewController {
    
    // MARK: - Properties
    let navigationBar: AppNavigationBar
    
    // MARK: - Init
    init(
        title: String,
        subtitle: String? = nil,
        avatarImage: UIImage? = nil,
        rightImage: UIImage? = nil
    ) {
        self.navigationBar = AppNavigationBar(
            title: title,
            subtitle: subtitle,
            avatarImage: avatarImage,
            rightImage: rightImage
        )
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBaseViews()
        setupBaseConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Получаем реальную высоту статус-бара (на SE это 20pt, на 17 Pro — около 59pt)
        let statusBarHeight = view.safeAreaInsets.top
        
        // Рабочая высота панели по вашему дизайну (129pt общей высоты на Pro минус ~59pt челки = 70pt)
        let contentBarHeight: CGFloat = 70.0
        
        // Обновляем констрейнт высоты навигейшн бара
        navigationBar.snp.updateConstraints { make in
            make.height.equalTo(statusBarHeight + contentBarHeight)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Private Setup
    private func setupBaseViews() {
        view.backgroundColor = AppColors.background
        view.addSubview(navigationBar)
    }
    
    private func setupBaseConstraints() {
        navigationBar.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(129)
        }
    }
}
