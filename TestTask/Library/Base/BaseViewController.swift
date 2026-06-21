//
//  BaseViewController.swift
//  TestTask
//
//  Created by Vit Chernuhin on 21.06.2026.
//

import UIKit
import SnapKit
import XCoordinator

class BaseViewController<R: Route>: UIViewController {
    
    // MARK: - Properties
    let router: WeakRouter<R>
    
    // MARK: - UI Components
    private let backgroundView = BackgroundView()
    
    let navigationBar: AppNavigationBar
    
    // MARK: - Init
    init(title: String, router: WeakRouter<R>) {
        self.router = router
        self.navigationBar = AppNavigationBar(title: title)
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
        setupBaseActions()
    }
    
    // MARK: - Private Setup
    private func setupBaseViews() {
        view.addSubview(backgroundView)
        view.addSubview(navigationBar)
    }
    
    private func setupBaseConstraints() {
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        navigationBar.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(44)
        }
    }
    
    private func setupBaseActions() {
        navigationBar.onBackTapped = { [weak self] in
            if let navigationRoute = R.self as? MainRoute.Type {
                (self?.router as? WeakRouter<MainRoute>)?.trigger(.back)
            }
        }
    }
}
