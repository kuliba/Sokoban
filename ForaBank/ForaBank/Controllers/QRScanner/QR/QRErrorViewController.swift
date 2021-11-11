//
//  QRErrorViewController.swift
//  ForaBank
//
//  Created by Константин Савялов on 09.11.2021.
//

import UIKit

class QRErrorViewController: UIViewController{
    
    weak var delegate: QRErrorDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.title = "Сканировать QR-код"
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        self.navigationController?.isNavigationBarHidden = true
//    }

    @IBAction func goToTransfer(_ sender: UIButton) {
        delegate?.goToGKHMainController()
    }
    @IBAction func goToGKH(_ sender: UIButton) {
        delegate?.goToTransferByRequisites()
    }
}
