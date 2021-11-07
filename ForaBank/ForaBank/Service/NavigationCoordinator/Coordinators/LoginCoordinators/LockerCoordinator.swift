//
//  LockerCoordinator.swift
//  ForaBank
//
//  Created by Mikhail on 05.11.2021.
//

import UIKit

protocol LockerViewControllerDelegate: AnyObject {
    func goToTabBar()
}

class LockerCoordinator: Coordinator {
    

    let locker: AppLocker = AppLocker.loadFromStoryboard()

    override init(router: RouterType) {
        super.init(router: router)
        locker.mode = .login
        router.setRootModule(locker, hideBar: true)
    }
    
    init(router: RouterType, mode: ALMode) {
        super.init(router: router)
        locker.mode = mode
        router.setRootModule(locker, hideBar: true)
    }
    
    
    
    override func start() {
        locker.lockerDelegate = self
    }
    
}
 
extension LockerCoordinator: LockerViewControllerDelegate {
    
    func goToTabBar() {
        DispatchQueue.main.async { [self] in
            let mainTabBarCoordinator = MainTabBarCoordinator(router: self.router)
            self.addChild(mainTabBarCoordinator)
            mainTabBarCoordinator.start()
            self.router.push(mainTabBarCoordinator, animated: true) { [weak self, weak mainTabBarCoordinator] in
                self?.removeChild(mainTabBarCoordinator)
            }
        }
    }
    
}


