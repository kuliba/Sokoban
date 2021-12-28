import UIKit
import AVFoundation
import RealmSwift

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
//                    let foundByName = foundOperators?.filter{item in
//                        let nameOrg = dicQR["name"]
//                        return nameOrg?.lowercased().contains(item.name?.lowercased() ?? "####") == true
//                    }
//                    if foundByName?.count == 1 {
//                        navigationController?.popViewController(animated: true)
//                        operators = foundOperators?.first
//                        returnKey()
//                    } else {
                        GlobalModule.qrData = qrData
                        QRErrorViewController.operators.removeAll()
                        QRErrorViewController.operators.append(contentsOf: foundOperators!)
                        performSegue(withIdentifier: "qrError", sender: nil)
//                    }
                } else if foundOperators?.count ?? 0 == 1 {
                    navigationController?.popViewController(animated: true)
                    operators = foundOperators?.first
                    returnKey()
                } else if foundOperators?.count ?? 0 == 0 {
                    GlobalModule.qrData = nil
                    QRErrorViewController.operators.removeAll()
                    navigationController?.popViewController(animated: true)
                    performSegue(withIdentifier: "qrError", sender: nil)
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
