//
//  LockerCoordinator.swift
//  ForaBank
//
//  Created by Mikhail on 05.11.2021.
//

import UIKit

protocol LockerViewControllerDelegate: AnyObject {
    func goToTabBar()
}

class LockerCoordinator: Coordinator, LockerViewControllerDelegate {

    let locker = Bundle(for: AppLocker.classForCoder()).loadNibNamed(ALConstants.nibName, owner: self, options: nil)!.first as! AppLocker

    override init(router: RouterType) {
        super.init(router: router)
        locker.mode = .login
        router.setRootModule(locker, hideBar: true)
        locker.delegate = self
        
    }
    
    override func start() {
//        var config = ALOptions()
//        config.isSensorsEnabled = UserDefaults().object(forKey: "isSensorsEnabled") as? Bool
//
//        locker.messageLabel.text = config.title ?? ""
//        locker.submessageLabel.text = config.subtitle ?? ""
//        locker.view.backgroundColor = config.color ?? .white
//        locker.mode = .login
//        locker.onSuccessfulDismiss = config.onSuccessfulDismiss
//        locker.onFailedAttempt = config.onFailedAttempt
//
//        if config.isSensorsEnabled ?? false {
//            locker.checkSensors()
//        }
//
//        if let image = config.image {
//            locker.photoImageView.image = image
//        } else {
//            locker.photoImageView.isHidden = true
//        }
//        locker.modalPresentationStyle = .fullScreen
//        locker.delegate = self
//        locker.mode = .login
    }
    
    func goToTabBar() {
        let mainTabBarCoordinator = MainTabBarCoordinator(router: self.router)
        self.addChild(mainTabBarCoordinator)
        mainTabBarCoordinator.start()
        DispatchQueue.main.async { [self] in
            self.router.push(mainTabBarCoordinator, animated: true) { [weak self, weak mainTabBarCoordinator] in
                self?.removeChild(mainTabBarCoordinator)
            }
        }
    }
    
}
