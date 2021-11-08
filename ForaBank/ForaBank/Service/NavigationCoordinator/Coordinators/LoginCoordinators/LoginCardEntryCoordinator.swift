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
    
    override func start() {
    }

}

extension LoginCardEntryCoordinator: LoginCardEntryDelegate {
    func toCodeVerification(phone: String? = "") {
        DispatchQueue.main.async {
            let codeVerificationCoordinator = CodeVerificationCoordinator(router: self.router)
            codeVerificationCoordinator.codeVerificationVC.viewModel.phone = phone
            self.addChild(codeVerificationCoordinator)
            codeVerificationCoordinator.start()
            self.router.push(codeVerificationCoordinator.codeVerificationVC, animated: true) { [weak self, weak codeVerificationCoordinator] in
                self?.removeChild(codeVerificationCoordinator)
            }
        }
    }
}
