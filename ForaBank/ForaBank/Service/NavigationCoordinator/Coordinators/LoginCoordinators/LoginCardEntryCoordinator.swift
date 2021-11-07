//
//  BaseViewController.swift
//  ForaBank
//
//  Created by Константин Савялов on 20.10.2021.
//

import UIKit

protocol LoginCardEntryDelegate: AnyObject {
    func toCodeVerification(phone: String?)
}

class LoginCardEntryCoordinator: Coordinator {


    let loginCardEntryVC = LoginCardEntryViewController()

    override init(router: RouterType) {
        super.init(router: router)
        loginCardEntryVC.delegate = self
        router.setRootModule(loginCardEntryVC, hideBar: false)
    }
    
    deinit {
        print("deinit LoginCardEntryViewController")
    }
    
    override func start() {
    }

}

extension LoginCardEntryCoordinator: LoginCardEntryDelegate {
    func toCodeVerification(phone: String? = "") {
        
        let coordinator = CodeVerificationCoordinator(router: router)
        coordinator.codeVerificationVC.viewModel.phone = phone
        coordinator.start()
        
    }
}
