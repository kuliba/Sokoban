//
//  FaceTouchIDCoordinator.swift
//  ForaBank
//
//  Created by Константин Савялов on 26.10.2021.
//

import Foundation

class FaceTouchIDCoordinator: Coordinator, FaceTouchIdViewControllerDelegate {
    func selectTransition() {
        let mainTabBarCoordinator = MainTabBarCoordinator(router: router)
        addChild(mainTabBarCoordinator)
        mainTabBarCoordinator.start()
        router.push(mainTabBarCoordinator, animated: true) { [weak self, weak mainTabBarCoordinator] in
            self?.removeChild(mainTabBarCoordinator)
        }
    }
    


    let accountViewController = FaceTouchIdViewController()

    override init(router: RouterType) {
        super.init(router: router)
        router.setRootModule(accountViewController, hideBar: false)
    }
    
    override func start() {
        selectTransition()
    }

}
