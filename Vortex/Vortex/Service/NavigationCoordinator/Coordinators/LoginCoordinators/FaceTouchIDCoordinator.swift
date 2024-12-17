//
//  FaceTouchIDCoordinator.swift
//  ForaBank
//
//  Created by Константин Савялов on 26.10.2021.
//

import Foundation

protocol FaceTouchIDCoordinatorDelegate: AnyObject {
    func goToTabBar()
}

class FaceTouchIDCoordinator: Coordinator {

    let accountViewController = FaceTouchIdViewController()

    override init(router: RouterType) {
        super.init(router: router)
        accountViewController.delegate = self
    }
    
    deinit {
        
    }
    
    override func start() {
    }

}

extension FaceTouchIDCoordinator: FaceTouchIDCoordinatorDelegate {
    func goToTabBar() {
        DispatchQueue.main.async {
            let mainTabBarCoordinator = MainTabBarCoordinator(router: self.router)
            self.addChild(mainTabBarCoordinator)
            mainTabBarCoordinator.start()
        }
    }
}
