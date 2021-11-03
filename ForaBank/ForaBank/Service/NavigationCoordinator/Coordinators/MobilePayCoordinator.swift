//
//  MobilePayCoordinator.swift
//  ForaBank
//
//  Created by Константин Савялов on 27.10.2021.
//

import UIKit

class MobilePayCoordinator: Coordinator {


    let mobilePayViewController = MobilePayViewController()

    override init(router: RouterType) {
        super.init(router: router)
        router.setRootModule(mobilePayViewController, hideBar: true)
    }
    
    override func start() {
    }
    
    override func toPresentable() -> UIViewController {
        return mobilePayViewController
    }
}
