//
//  GKHCoordinator.swift
//  ForaBank
//
//  Created by Константин Савялов on 10.11.2021.
//

import UIKit

protocol GKHDelegate: AnyObject {
    func goToQRController()
    func goToBack()
}

class GKHCoordinator: Coordinator, UINavigationControllerDelegate {

    let gkhViewController = UIStoryboard(name: "GKHStoryboard", bundle: nil).instantiateViewController(withIdentifier: "GKHMain") as! GKHMainViewController

    override init(router: RouterType) {
        super.init(router: router)
        gkhViewController.delegate = self
        
    }
    
    override func start() {
        gkhViewController.modalPresentationStyle = .fullScreen
    }
    
    override func toPresentable() -> UIViewController {
        return gkhViewController
    }
    
    deinit {
        print("Deinit GKHCoordinator")
    }
}

extension GKHCoordinator: GKHDelegate {
    
    func goToQRController() {
        let qrCoordinator = QRCoordinator(router: router)
        addChild(qrCoordinator)
        qrCoordinator.start()
        router.push(qrCoordinator, animated: true) {
            [weak self, weak qrCoordinator] in
                self?.removeChild(qrCoordinator)
        }
    }
    
    func goToBack() {
        router.popToRootModule(animated: true)
    }
    
}
