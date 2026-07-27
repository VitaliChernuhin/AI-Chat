//
//  Routable.swift
//  TestTask
//
//  Created by Vit Chernuhin on 24.06.2026.
//

import XCoordinator

protocol Routable: AnyObject {
    associatedtype TargetRoute: Route

    var router: WeakRouter<TargetRoute> { get }
}
