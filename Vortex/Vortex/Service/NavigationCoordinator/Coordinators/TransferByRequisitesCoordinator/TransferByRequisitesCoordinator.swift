//
//  TransferByRequisitesCoordinator.swift
//  ForaBank
//
//  Created by Константин Савялов on 10.11.2021.
//

import UIKit

class TransferByRequisitesCoordinator: Coordinator {

    let transferByRequisitesViewController = UINavigationController(rootViewController: TransferByRequisitesViewController())

    override init(router: RouterType) {
        super.init(router: router)
    }
    
    override func start() {
        transferByRequisitesViewController.modalPresentationStyle = .fullScreen
    }
    
    override func toPresentable() -> UIViewController {
        return transferByRequisitesViewController
    }
}
