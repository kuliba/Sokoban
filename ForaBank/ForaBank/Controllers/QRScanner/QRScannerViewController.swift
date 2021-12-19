//
//  QRScannerViewController.swift
//  ForaBank
//
//  Created by Дмитрий on 13.07.2021.
//

import UIKit
import QRScanner

final class QRScannerViewController: UIViewController {

    public var buttonComplete: UIButton?
    public var buttonConfirmTitle = "Закрыть"
    public var buttonConfirmBackgroundColor: UIColor = .red

    override func viewDidLoad() {
        super.viewDidLoad()

        let qrScannerView = QRScannerView(frame: view.bounds)
        view.addSubview(qrScannerView)
        qrScannerView.configure(delegate: self, input: .init(isBlurEffectEnabled: true))
        qrScannerView.startRunning()
        let buttomItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(scanCompleted))
        buttomItem.tintColor = .black
        navigationItem.leftBarButtonItem = buttomItem
        let widht = UIScreen.main.bounds.width - (UIScreen.main.bounds.width * 0.2)
        let viewX = (UIScreen.main.bounds.width / 2) - (widht / 2)

        let buttonCompleteX = viewX
        let buttonCompleteY = UIScreen.main.bounds.height - 90
        buttonComplete = UIButton(frame: CGRect(x: buttonCompleteX, y: buttonCompleteY, width: 100, height: 50))
        buttonComplete?.setTitle(buttonConfirmTitle, for: .normal)
        buttonComplete?.backgroundColor = buttonConfirmBackgroundColor
        buttonComplete?.layer.cornerRadius = 10
        buttonComplete?.layer.masksToBounds = true
        buttonComplete?.addTarget(self, action: #selector(scanCompleted), for: .touchUpInside)

        view.addSubview(buttonComplete!)
        buttonComplete?.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor,
                paddingLeft: viewX, paddingBottom: 90, paddingRight: viewX, height: 50)
    }

    @objc func scanCompleted() {
        dismiss(animated: true, completion: nil)
    }

}

extension QRScannerViewController: QRScannerViewDelegate {
    func qrScannerView(_ qrScannerView: QRScannerView, didFailure error: QRScannerError) {
        print(error)
    }

    func qrScannerView(_ qrScannerView: QRScannerView, didSuccess code: String) {
        print(code)
        let dict = code.toDictionary()
        print(dict)
        if let res = try? JSONDecoder().decode(Root.self, from: Data(code.utf8)) {
            print(res.BankName)
            print(res.BankName)
        }
        dismiss(animated: true, completion: nil)
    }

    struct Root: Decodable {
        let PersonalAcc, BankName, BIC, CorrespAcc, PayeeINN, PersAcc, FIO, PayerAddress, Sum: String
    }
}

extension String {
    func toDictionary() -> NSDictionary {
        let blankDict: NSDictionary = [:]
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
