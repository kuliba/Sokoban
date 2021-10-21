//
//  AppCoordinator.swift
//  ForaBank
//
//  Created by Константин Савялов on 19.10.2021.
//

import Foundation
import UIKit

class AppCoordinator: Coordinator<DeepLink> {
    
    let viewController = UIViewController()
    
    override init(router: RouterType) {
        super.init(router: router)
        viewController.view.backgroundColor = .blue
    }
    
    // We must override toPresentable() so it doesn't
    // default to the router's navigationController
    override func toPresentable() -> UIViewController {
        return viewController
    }
}
