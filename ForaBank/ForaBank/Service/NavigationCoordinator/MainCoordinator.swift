//
//  AppCoordinator.swift
//  ForaBank
//
//  Created by Константин Савялов on 19.10.2021.
//

import Foundation
import UIKit


class MainCoordinator: Coordinator {
    
    let coordinator: Coordinator!
    
    override init(router: RouterType) {
        coordinator = BaseCoordinator(router: router)
        super.init(router: router)
        router.setRootModule(coordinator.toPresentable(), hideBar: true)
    }
    
    override func start() {
        
//        goTabBar()
        let userIsRegister = UserDefaults.standard.object(forKey: "UserIsRegister") as? Bool
        if let userIsRegister = userIsRegister {
            if userIsRegister {
                self.goToPinVC()
            } else {
                self.goToRegisterVC()
            }
        } else {
            self.goToRegisterVC()
        }
    }
    
    func goToRegisterVC() {
        let loginCoordinator = LoginCardEntryCoordinator(router: router)
        addChild(loginCoordinator)
        loginCoordinator.start()
        DispatchQueue.main.async { [self] in
            router.push(loginCoordinator, animated: true) { [weak self, weak coordinator] in
                self?.removeChild(coordinator)
            }
        }
    }
    
    func goToPinVC() {
        let lockerCoordinator = LockerCoordinator(router: self.router)
        self.addChild(lockerCoordinator)
        lockerCoordinator.start()
        DispatchQueue.main.async { [self] in
            self.router.push(lockerCoordinator, animated: true) { [weak self, weak coordinator] in
                self?.removeChild(coordinator)
            }
        }
    }
    
    func goTabBar() {
        let mainTabBarCoordinator = MainTabBarCoordinator(router: self.router)
        self.addChild(mainTabBarCoordinator)
        mainTabBarCoordinator.start()
        DispatchQueue.main.async { [self] in
            self.router.push(mainTabBarCoordinator, animated: true) { [weak self, weak coordinator] in
                self?.removeChild(coordinator)
            }
        }
    }
}


class BaseCoordinator: Coordinator {
    
    var viewController = UIViewController()
    
    override init(router: RouterType) {
        super.init(router: router)
        viewController.view.backgroundColor = .brown
    }
    
    override func toPresentable() -> UIViewController {
        return viewController
    }
    
}
