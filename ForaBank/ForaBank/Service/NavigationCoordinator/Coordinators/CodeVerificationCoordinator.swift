//
//  CodeVerificationCoordinator.swift
//  ForaBank
//
//  Created by Mikhail on 29.10.2021.
//

import UIKit

protocol CodeVerificationDelegate: AnyObject {
    func goNextController()
}

class CodeVerificationCoordinator: Coordinator {

    let accountViewController = CodeVerificationViewController(model: CodeVerificationViewModel( type: .register))

    override init(router: RouterType) {
        super.init(router: router)
        accountViewController.delegate = self
        router.setRootModule(accountViewController, hideBar: false)
    }
    
    override func start() {
    }
}


extension CodeVerificationCoordinator: CodeVerificationDelegate {
    
    func goNextController() {
        let navigationController = UINavigationController()
        let newRouter = Router(navigationController: navigationController)
        let coordinator = FaceTouchIDCoordinator(router: newRouter)
        coordinator.start()
    }

}
