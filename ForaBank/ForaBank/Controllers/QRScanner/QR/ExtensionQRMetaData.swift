//
//  ExtensionQRMetaData.swift
//  ForaBank
//
//  Created by Константин Савялов on 03.09.2021.
//

import UIKit
import AVFoundation
import RealmSwift

extension QRViewController: AVCaptureMetadataOutputObjectsDelegate, CALayerDelegate {

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard metadataObjects.count > 0 else { return }
        if let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject {
            if object.type == AVMetadataObject.ObjectType.qr {
                self.keyValue = object.stringValue ?? ""
                let a = self.keyValue.components(separatedBy: "|")
                
                a.forEach { [weak self] v in
                    if v.contains("=") {
                        let tempArray = v.components(separatedBy: "=")
                        var key = tempArray[0]
                        let value = tempArray[1]
                        if key == "persAcc" {
                            key = "Лицевой счет"
                        }
                        self?.qrData.updateValue(value, forKey: key)
                    }
                }
                
                let inn = qrData.filter { $0.key == "PayeeINN" }
                operatorsList?.forEach({ operators in
                    if operators.synonymList.first == inn.values.first {
                        self.operators = operators
                    }
                })
                self.returnKey()
            } else {
                DispatchQueue.main.async {
                    guard self.alertController == nil else {
                        print("There is already an alert presented")
                        return
                    }
                    self.alertController = UIAlertController(title: "Код не получен", message: object.stringValue ?? "", preferredStyle: .actionSheet)
                    guard let alert = self.alertController else {
                        return
                    }
                    alert.addAction(UIAlertAction(title: "Повторить попытку", style: .default, handler: { (action) in
                        print(object.stringValue ?? "")
                        self.alertController = nil
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        
    }
    
}
