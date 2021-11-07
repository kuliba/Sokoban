//
//  CodeVerificationCoordinator.swift
//  ForaBank
//
//  Created by Mikhail on 29.10.2021.
//

import UIKit

protocol CodeVerificationDelegate: AnyObject {
    func goNextController()
    func goToCreatePinVC()
}

class CodeVerificationCoordinator: Coordinator {

    let codeVerificationVC = CodeVerificationViewController(model: CodeVerificationViewModel(type: .register))

    override init(router: RouterType) {
        super.init(router: router)
        codeVerificationVC.delegate = self
        router.setRootModule(codeVerificationVC, hideBar: false)
    }
    
    override func start() {
    }
}


extension CodeVerificationCoordinator: CodeVerificationDelegate {
    
    func goToCreatePinVC() {
        let newRouter = Router()
        let lockerCoordinator = LockerCoordinator(router: newRouter, mode: .create)
        lockerCoordinator.start()
    }
    
    func goNextController() {
        let navigationController = UINavigationController()
        let newRouter = Router(navigationController: navigationController)
        let coordinator = FaceTouchIDCoordinator(router: newRouter)
        coordinator.start()
    }

}
