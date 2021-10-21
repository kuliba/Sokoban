//
//  BaseViewController.swift
//  ForaBank
//
//  Created by Константин Савялов on 20.10.2021.
//

import UIKit

class AccountCoordinator: Coordinator<DeepLink> {
    
    
    let accountViewController = UIViewController()
    
    override init(router: RouterType) {
        super.init(router: router)
        accountViewController.view.backgroundColor = .magenta
        router.setRootModule(accountViewController, hideBar: false)
    }

}
