//
//  QRCoordinator.swift
//  ForaBank
//
//  Created by Константин Савялов on 09.11.2021.
//

import UIKit

protocol QRCoordinatorDelegate: AnyObject {
    func goToQRError()
}

class QRCoordinator: Coordinator {
    
    let qrViewController = UIStoryboard(name: "QRCodeStoryboard", bundle: nil).instantiateViewController(withIdentifier: "qr") as! QRViewController

    override init(router: RouterType) {
        super.init(router: router)
        qrViewController.qrCoordinatorDelegate = self
    }
    
    override func start() {
        qrViewController.modalPresentationStyle = .fullScreen
    }
    
    override func toPresentable() -> UIViewController {
        return qrViewController
    }
}

extension QRCoordinator: QRCoordinatorDelegate {
    
    func goToQRError() {
        let qrErrorCoordinator = QRErrorCoordinator(router: router)
        addChild(qrErrorCoordinator)
        qrErrorCoordinator.start()
        router.push(qrErrorCoordinator.toPresentable(), animated: true) {
            [weak self, weak qrErrorCoordinator] in
                self?.removeChild(qrErrorCoordinator)
        }
    }
    
}
