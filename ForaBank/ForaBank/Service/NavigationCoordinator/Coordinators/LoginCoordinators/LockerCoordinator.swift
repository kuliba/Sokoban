//
//  LockerCoordinator.swift
//  ForaBank
//
//  Created by Mikhail on 05.11.2021.
//

import UIKit

protocol LockerViewControllerDelegate: AnyObject {
    func goToTabBar()
    func goToFaceId(pin: String)
}

class LockerCoordinator: Coordinator {
    

    let locker: AppLocker = AppLocker.loadFromStoryboard()

    override init(router: RouterType) {
        super.init(router: router)
        locker.mode = .login
        locker.lockerDelegate = self
        router.setRootModule(locker, hideBar: true)
    }
    
    init(router: RouterType, mode: ALMode) {
        super.init(router: router)
        locker.mode = mode
        locker.lockerDelegate = self
    }
    
    override func start() {
    }
    
}
 
extension LockerCoordinator: LockerViewControllerDelegate {
    
    func goToFaceId(pin: String) {
        DispatchQueue.main.async { [self] in
            let faceTouchIDCoordinator = FaceTouchIDCoordinator(router: self.router)
            faceTouchIDCoordinator.accountViewController.code = pin
            self.addChild(faceTouchIDCoordinator)
            faceTouchIDCoordinator.start()
            self.router.push(faceTouchIDCoordinator.accountViewController, animated: true) { [weak self, weak faceTouchIDCoordinator] in
                self?.removeChild(faceTouchIDCoordinator)
            }
        }
        
    }
    
    func goToTabBar() {
        DispatchQueue.main.async { [self] in
            let mainTabBarCoordinator = MainTabBarCoordinator(router: self.router)
            self.addChild(mainTabBarCoordinator)
            mainTabBarCoordinator.start()
        }
    }
    
}


