//
//  QRScannerViewController.swift
//  ForaBank
//
//  Created by Дмитрий on 13.07.2021.
//

import UIKit
import QRScanner

final class QRScannerViewController: UIViewController {
        override func viewDidLoad() {
            super.viewDidLoad()

            let qrScannerView = QRScannerView(frame: view.bounds)
            view.addSubview(qrScannerView)
            qrScannerView.configure(delegate: self, input: .init(isBlurEffectEnabled: true))
            qrScannerView.startRunning()
        }
    }

    extension QRScannerViewController: QRScannerViewDelegate {
        func qrScannerView(_ qrScannerView: QRScannerView, didFailure error: QRScannerError) {
            print(error)
        }

        func qrScannerView(_ qrScannerView: QRScannerView, didSuccess code: String) {
            print(code)
           let dict =  code.toDictionary()
            print(dict)
            if let res = try? JSONDecoder().decode(Root.self, from: Data(code.utf8)) {
                print(res.BankName)
                print(res.BankName)
            }
            dismiss(animated: true, completion: nil)
        }

        struct Root : Decodable {
            let PersonalAcc,BankName,BIC, CorrespAcc,PayeeINN, PersAcc, FIO, PayerAddress, Sum :String
        }
    }

extension String{
    func toDictionary() -> NSDictionary {
        let blankDict : NSDictionary = [:]
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
            } catch {
                print(error.localizedDescription)
            }
        }
        return blankDict
    }
}
