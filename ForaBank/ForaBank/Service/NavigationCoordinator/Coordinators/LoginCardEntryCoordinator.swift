//
//  BaseViewController.swift
//  ForaBank
//
//  Created by Константин Савялов on 20.10.2021.
//

import UIKit

class LoginCardEntryCoordinator: Coordinator {


    let accountViewController = LoginCardEntryViewController()

    override init(router: RouterType) {
        super.init(router: router)
        router.setRootModule(accountViewController, hideBar: false)
    }
    
    override func start() {
    }

}
