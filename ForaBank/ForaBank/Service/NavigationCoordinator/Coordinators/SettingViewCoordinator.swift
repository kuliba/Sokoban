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
        settingsViewController.addCloseButton_setting()
        settingsViewController.delegate = self
    }
    
    override func start() {
    }
    
    override func toPresentable() -> UIViewController {
        let navVC = UINavigationController(rootViewController: settingsViewController)
        navVC.modalPresentationStyle = .fullScreen
//        navVC.addCloseButton()
        return navVC
    }
}


extension SettingViewCoordinator: SettingTableViewControllerDelegate {
    func goLoginCardEntry() {
        let mySceneDelegate = settingsViewController.view.window?.windowScene?.delegate as? SceneDelegate

        let appNavigation = UINavigationController()
        mySceneDelegate?.appNavigationController = appNavigation
        let router = Router(navigationController: appNavigation)
        mySceneDelegate?.appRouter = router
        mySceneDelegate?.appCoordinator = MainCoordinator(router: router)
        
        mySceneDelegate?.window?.rootViewController = mySceneDelegate?.appCoordinator.toPresentable()
        mySceneDelegate?.window?.makeKeyAndVisible()
        mySceneDelegate?.appCoordinator.start()
    }
}
