//
//  MobilePayCoordinator.swift
//  ForaBank
//
//  Created by Константин Савялов on 27.10.2021.
//

import UIKit

class MobilePayCoordinator: Coordinator {
    
    let mobilePayViewController = UINavigationController(rootViewController: MobilePayViewController()) 

    override init(router: RouterType) {
        super.init(router: router)
    }
    
    override func start() {
        mobilePayViewController.modalPresentationStyle = .fullScreen
    }
    
    override func toPresentable() -> UIViewController {
        return mobilePayViewController
    }
}
