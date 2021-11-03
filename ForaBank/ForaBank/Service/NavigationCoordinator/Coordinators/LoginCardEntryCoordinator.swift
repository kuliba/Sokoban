//
//  BaseViewController.swift
//  ForaBank
//
//  Created by Константин Савялов on 20.10.2021.
//

import UIKit

protocol LoginCardEntryDelegate: AnyObject {
    func goNextController()
}

class LoginCardEntryCoordinator: Coordinator {


    let accountViewController = LoginCardEntryViewController()

    override init(router: RouterType) {
        super.init(router: router)
        accountViewController.delegate = self
        router.setRootModule(accountViewController, hideBar: false)
    }
    
    override func start() {
    }

}

extension LoginCardEntryCoordinator: LoginCardEntryDelegate {
    func goNextController() {
        
        let coordinator = CodeVerificationCoordinator(router: router)
//        addChild(coordinator)
        coordinator.start()
//        router.push(coordinator, animated: true) { [weak self, weak coordinator] in
//            self?.removeChild(coordinator)
//        }
    }
}
