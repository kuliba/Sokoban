//
//  SettingViewCoordinator.swift
//  ForaBank
//
//  Created by Mikhail on 08.11.2021.
//

import UIKit

class SettingViewCoordinator: Coordinator {

    let settingsViewController: SettingTableViewController =  SettingTableViewController.loadFromStoryboard()

    override init(router: RouterType) {
        super.init(router: router)
        settingsViewController.delegate = self
    }
    
    override func start() {
    }
    
    override func toPresentable() -> UIViewController {
        let navVC = UINavigationController(rootViewController: settingsViewController)
        navVC.modalPresentationStyle = .fullScreen
        navVC.addCloseButton()
        return navVC
    }
}


extension SettingViewCoordinator: SettingTableViewControllerDelegate {
    func goLoginCardEntry() {
        let loginCoordinator = LoginCardEntryCoordinator(router: router)
        addChild(loginCoordinator)
        loginCoordinator.start()
    }
}
