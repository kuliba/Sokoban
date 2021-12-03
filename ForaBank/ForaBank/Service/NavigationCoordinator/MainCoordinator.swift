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
        
        let userIsRegister = UserDefaults.standard.object(forKey: "UserIsRegister") as? Bool
        
        // Зарузка кэша
        DispatchQueue.main.async(qos: .userInteractive) {
        lazy var downloadCash = DownloadQueue()
        downloadCash.download {}
        }
        
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
    }
    
    func goToPinVC() {
        let lockerCoordinator = LockerCoordinator(router: self.router)
        self.addChild(lockerCoordinator)
        lockerCoordinator.start()
    }
    
}


class BaseCoordinator: Coordinator {
    
    var viewController = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()!
    
    override init(router: RouterType) {
        super.init(router: router)
    }
    
    override func toPresentable() -> UIViewController {
        return viewController
    }
    
}
