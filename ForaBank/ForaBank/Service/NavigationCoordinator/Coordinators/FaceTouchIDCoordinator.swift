//
//  FaceTouchIDCoordinator.swift
//  ForaBank
//
//  Created by Константин Савялов on 26.10.2021.
//

import Foundation

protocol FaceTouchIDCoordinatorDelegate: AnyObject {
    func goNextController()
}

class FaceTouchIDCoordinator: Coordinator {

    let accountViewController = FaceTouchIdViewController()

    override init(router: RouterType) {
        super.init(router: router)
        accountViewController.delegate = self
        router.setRootModule(accountViewController, hideBar: false)
    }
    
    override func start() {
        
    }

}

extension FaceTouchIDCoordinator: FaceTouchIDCoordinatorDelegate {
    func goNextController() {
        let mainTabBarCoordinator = MainTabBarCoordinator(router: router)
        addChild(mainTabBarCoordinator)
        mainTabBarCoordinator.start()
        router.push(mainTabBarCoordinator, animated: true) { [weak self, weak mainTabBarCoordinator] in
            self?.removeChild(mainTabBarCoordinator)
        }
    }
}
