//
//  CountryPayCoordinator.swift
//  ForaBank
//
//  Created by Mikhail on 29.10.2021.
//

import UIKit

class CountryPayCoordinator: Coordinator {

    let сontactInputViewController = UINavigationController(rootViewController: ChooseCountryTableViewController())

    override init(router: RouterType) {
        super.init(router: router)
    }
    
    override func start() {
        сontactInputViewController.modalPresentationStyle = .fullScreen
    }
    
    override func toPresentable() -> UIViewController {
        return сontactInputViewController
    }
}
