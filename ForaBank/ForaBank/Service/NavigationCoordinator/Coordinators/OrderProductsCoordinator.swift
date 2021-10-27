//
//  OrderProductsCoordinator.swift
//  ForaBank
//
//  Created by Константин Савялов on 26.10.2021.
//

import Foundation

class OrderProductsCoordinator: Coordinator {


    let accountViewController = OrderProductsViewController()

    override init(router: RouterType) {
        super.init(router: router)
        router.setRootModule(accountViewController, hideBar: false)
    }
    
    override func start() {
    }
}
