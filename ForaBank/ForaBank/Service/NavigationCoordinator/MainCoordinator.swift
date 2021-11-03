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
        router.setRootModule(coordinator.toPresentable(), hideBar: true)
        super.init(router: router)
    }
    
    override func start() {
        
        //       goTabBar()
        let userIsRegister = UserDefaults.standard.object(forKey: "UserIsRegister") as? Bool
        if let userIsRegister = userIsRegister {
            if userIsRegister {
                self.goToPinVC(.validate)
            } else {
                self.goToRegisterVC()
            }
        } else {
            self.goToRegisterVC()
        }
    }
    
    //    override func toPresentable() -> UIViewController {
    //        return viewController
    //    }
    
    func goToRegisterVC() {
        
        let loginCoordinator = LoginCardEntryCoordinator(router: router)
        addChild(loginCoordinator)
        loginCoordinator.start()
        router.push(loginCoordinator, animated: true) { [weak self, weak coordinator] in
            self?.removeChild(coordinator)
        }
    }
    
    func goToPinVC(_ mode: ALMode) {
        var options = ALOptions()
        options.isSensorsEnabled = UserDefaults().object(forKey: "isSensorsEnabled") as? Bool
        options.onSuccessfulDismiss = { (mode: ALMode?, _) in
            self.goTabBar()
        }
        options.onFailedAttempt = { (mode: ALMode?) in
            print("Failed to \(String(describing: mode))")
        }
        AppLocker.rootViewController(with: mode, and: options, window: UIApplication.shared.windows.first)
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
