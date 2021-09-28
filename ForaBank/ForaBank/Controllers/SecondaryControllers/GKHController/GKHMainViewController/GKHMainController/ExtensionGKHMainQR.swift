//
//  ExtensionGKHMainQR.swift
//  ForaBank
//
//  Created by Константин Савялов on 03.09.2021.
//

import Foundation

extension GKHMainViewController: QRProtocol {
    
    func setResultOfBusinessLogic(_ qr: [String : String], _ model: GKHOperatorsModel) {
        self.qrData = qr
        self.operators = model
        self.performSegue(withIdentifier: "input", sender: self)
    }
}
