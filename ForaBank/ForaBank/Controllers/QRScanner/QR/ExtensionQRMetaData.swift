import UIKit
import AVFoundation

extension QRViewController: AVCaptureMetadataOutputObjectsDelegate, CALayerDelegate {

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard metadataObjects.count > 0, !qrIsFired else { return }
        qrIsFired = true
        var tempInn = ""
        if let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject {
            if object.type == AVMetadataObject.ObjectType.qr {
                keyValue = object.stringValue ?? ""
                let a = keyValue.components(separatedBy: "|")

                var dicQR = [String: String]()
                a.forEach { [weak self] v in
                    if v.contains("qr.nspk.ru") {
                        onC2B(link: v)
                        return
                    }

                    if v.contains("=") {
                        let tempArray = v.components(separatedBy: "=")
                        var key = tempArray[0].lowercased()
                        let value = tempArray[1]
                        dicQR[key] = value
                        if key == "persacc" {
                            key = "Лицевой счет"
                            self?.qrData.updateValue(value, forKey: key)
                        }
                        if key == "sum" {
                            key = "Сумма"
                            self?.qrData.updateValue(value, forKey: key)
                        }
                        if key == "payeeinn" {
                            tempInn = value
                        }
                        if key == "personalacc" {
                            key = "Pасчетный счет Получателя"
                            self?.qrData.updateValue(value, forKey: key)
                        }
                    }
                }

                let foundOperators = operatorsList?.filter{ item in
                    if item.synonymList.count > 0 {
                        return item.synonymList.first == tempInn
                    } else {
                        return  false
                    }
                }

                if foundOperators?.count ?? 0 > 1 {
                    GlobalModule.qrData = qrData
                    QRErrorViewController.operators.removeAll()
                    if let foundOperators = foundOperators {
                        
                        QRErrorViewController.operators.append(contentsOf: foundOperators)
                    }
                    
                    let storyboard = UIStoryboard(name: "QRCodeStoryboard", bundle: nil)
                    
                    if let vc = storyboard.instantiateViewController(withIdentifier: "qrError") as? QRErrorViewController {
                        
                        self.present(vc, animated: true)
                    }
                } else if foundOperators?.count ?? 0 == 1 {

                    operators = foundOperators?.first
                    returnKey()
                } else if foundOperators?.count ?? 0 == 0 {
                    GlobalModule.qrData = nil
                    QRErrorViewController.operators.removeAll()
                    let storyboard = UIStoryboard(name: "QRCodeStoryboard", bundle: nil)
                    
                    if let vc = storyboard.instantiateViewController(withIdentifier: "qrError") as? QRErrorViewController {
                        
                        self.present(vc, animated: true)
                    }
                }
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
