//
//  QRErrorCoordinator.swift
//  ForaBank
//
//  Created by Константин Савялов on 10.11.2021.
//

import UIKit

protocol QRErrorDelegate: AnyObject {
    func goToTransferByRequisites()
    func goToGKHMainController()
}

class QRErrorCoordinator: Coordinator {

    let qrErrorViewController = UIStoryboard(name: "QRCodeStoryboard", bundle: nil).instantiateViewController(withIdentifier: "qrError") as! QRErrorViewController

    override init(router: RouterType) {
        super.init(router: router)
        qrErrorViewController.delegate = self
    }
    
    override func start() {
        qrErrorViewController.modalPresentationStyle = .fullScreen
    }
    
    override func toPresentable() -> UIViewController {
        return qrErrorViewController
    }
}

extension QRErrorCoordinator: QRErrorDelegate {
    
    func goToTransferByRequisites() {
        let transferCoordinator = TransferByRequisitesCoordinator(router: router)
        addChild(transferCoordinator)
        transferCoordinator.start()
        router.push(transferCoordinator, animated: true) {
            [weak self, weak transferCoordinator] in
                self?.removeChild(transferCoordinator)
        }
    }
    
    func goToGKHMainController() {
//        let gkhCoordinator = GKHCoordinator(router: router)
//        addChild(gkhCoordinator)
//        gkhCoordinator.start()
//        router.push(gkhCoordinator.toPresentable(), animated: true) {
//            [weak self, weak gkhCoordinator] in
//                self?.removeChild(gkhCoordinator)
//        }
    }
    
}

