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
                self.goToPinVC(.login)
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
        
        DispatchQueue.main.async {
            let navigationController = UINavigationController()
            let newRouter = Router(navigationController: navigationController)
            let coordinator = LockerCoordinator(router: newRouter)
            coordinator.start()
            newRouter.setRootModule(coordinator, hideBar: true)
//            coordinator.start()
            
//            AppLocker.present(with: mode, over: coordinator.toPresentable())
//        AppLocker.present(with: mode, and: options)
        
        }
    }
    
    func goTabBar() {
        DispatchQueue.main.async {
            let navigationController = UINavigationController()
            let newRouter = Router(navigationController: navigationController)
            let coordinator = MainTabBarCoordinator(router: newRouter)
            coordinator.start()
            newRouter.setRootModule(coordinator, hideBar: true)
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
