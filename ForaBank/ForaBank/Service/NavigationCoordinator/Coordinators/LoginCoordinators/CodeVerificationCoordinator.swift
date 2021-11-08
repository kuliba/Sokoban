//
//  CodeVerificationCoordinator.swift
//  ForaBank
//
//  Created by Mikhail on 29.10.2021.
//

import UIKit

protocol CodeVerificationDelegate: AnyObject {
    func goToCreatePinVC()
}

class CodeVerificationCoordinator: Coordinator {

    let codeVerificationVC = CodeVerificationViewController(model: CodeVerificationViewModel(type: .register))

    override init(router: RouterType) {
        super.init(router: router)
        codeVerificationVC.delegate = self
    }
    
    override func start() {
    }
}


extension CodeVerificationCoordinator: CodeVerificationDelegate {
    
    func goToCreatePinVC() {
        DispatchQueue.main.async {
            let lockerCoordinator = LockerCoordinator(router: self.router, mode: .create)
            self.addChild(lockerCoordinator)
            lockerCoordinator.start()
            self.router.push(lockerCoordinator.locker, animated: true) { [weak self, weak lockerCoordinator] in
                self?.removeChild(lockerCoordinator)
            }
        }
    }
    
}
