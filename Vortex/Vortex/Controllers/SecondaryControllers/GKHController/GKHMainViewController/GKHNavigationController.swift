//
//  GKHNavigationController.swift
//  ForaBank
//
//  Created by Константин Савялов on 10.11.2021.
//

import UIKit

protocol GKHNavigationDelegate: AnyObject {
    func goToQRController()
}

class GKHNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
}
