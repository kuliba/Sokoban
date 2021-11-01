//
//  CountryPayCoordinator.swift
//  ForaBank
//
//  Created by Mikhail on 29.10.2021.
//

import UIKit

class CountryPayCoordinator: Coordinator {


    let mobilePayViewController = ContactInputViewController()

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
