//
//  AppAlertViewController.swift
//  TestTask
//
//  Created by Vit Chernuhin on 27.06.2026.
//

import UIKit

final class AppAlertViewController: UIViewController {
    
    // MARK: - Properties
    private let alertType: AppAlertView.AlertType
    private let message: String
    
    private lazy var mainView = AppAlertView(type: alertType, message: message)
    
    // MARK: - Init
    init(type: AppAlertView.AlertType, message: String) {
        self.alertType = type
        self.message = message
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func loadView() {
        view = mainView
    }
}
