//
//  AppAlertTransitionAnimation.swift
//  TestTask
//
//  Created by Vit Chernuhin on 27.06.2026.
//

import UIKit
import XCoordinator

final class AppAlertTransitionAnimation: StaticTransitionAnimation {
    
    init(isPresenting: Bool) {
        let duration: TimeInterval = isPresenting ? 0.3 : 0.25
        
        super.init(duration: duration, performAnimation: { transitionContext in
            // Достаем контроллеры из контекста переходов UIKit
            guard let toVC = transitionContext.viewController(forKey: .to),
                  let fromVC = transitionContext.viewController(forKey: .from) else {
                transitionContext.completeTransition(false)
                return
            }
            
            let containerView = transitionContext.containerView
            
            if isPresenting {
                // 1. ЛОГИКА ПОЯВЛЕНИЯ (Present)
                containerView.addSubview(toVC.view)
                toVC.view.frame = containerView.bounds
                
                // Добираемся до вьюхи алерта и готовим ее к прыжку
                let alertView = toVC.view as? AppAlertView
                alertView?.prepareForPresentationAnimation()
                
                UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
                    alertView?.performPresentationAnimation()
                }) { _ in
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                }
            } else {
                // 2. ЛОГИКА ИСЧЕЗНОВЕНИЯ (Dismiss)
                let alertView = fromVC.view as? AppAlertView
                
                UIView.animate(withDuration: duration, delay: 0, options: .curveEaseIn, animations: {
                    alertView?.performDismissalAnimation()
                }) { _ in
                    fromVC.view.removeFromSuperview()
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                }
            }
        })
    }
}
