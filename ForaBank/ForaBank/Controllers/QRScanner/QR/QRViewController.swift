//
//  QRViewController.swift
//  ForaBank
//
//  Created by Константин Савялов on 18.08.2021.
//

import UIKit
import AVFoundation
import RealmSwift
import PDFKit


protocol QRProtocol: AnyObject {
    func setResultOfBusinessLogic(_ qr: [String: String], _ model: GKHOperatorsModel)
}

final class QRViewController: BottomPopUpViewAdapter, UIDocumentPickerDelegate {

    public static func storyboardInstance() -> QRViewController? {
        let storyboard = UIStoryboard(name: "QRCodeStoryboard", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "qr") as? QRViewController
    }

    weak var delegate: QRProtocol?
//    weak var qrCoordinatorDelegate: QRCoordinatorDelegate?

    var qrCodeLayer = AVCaptureVideoPreviewLayer()
    let qrCodesession = AVCaptureSession()
    var alertController: UIAlertController?

    @IBOutlet weak var pdfFile: UIButton!
    @IBOutlet weak var zap: UIButton!
    @IBOutlet weak var info: UIButton!

    let bottomSpace: CGFloat = 80.0
    var squareView: SquareView? = nil
    lazy var realm = try? Realm()
    var operatorsList: Results<GKHOperatorsModel>? = nil
    var keyValue = ""
    var qrData = [String: String]()
    var operators: GKHOperatorsModel? = nil
    var qrIsFired = false

    @IBOutlet weak var qrView: UIView!
    @IBOutlet weak var backButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        pdfFile.add_CornerRadius(30)
        zap.add_CornerRadius(30)
        info.add_CornerRadius(30)
        navigationController?.isNavigationBarHidden = true

        operatorsList = realm?.objects(GKHOperatorsModel.self)
        setupLayer()
        startQRCodeScanning()
        view.insertSubview(qrView, at: 1)
        backButton.setupButtonRadius()
    }

    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true)
    }

    @IBAction func info(_ sender: UIButton) {
        let infoView = QRScanerInfoView()
        self.showAlert(infoView)
    }

    @IBAction func zap(_ sender: UIButton) {
        let device = AVCaptureDevice.default(for: .video)
        if ((device?.hasTorch) != nil) {
            do {
                try device?.lockForConfiguration()
                device?.torchMode = device?.torchMode == AVCaptureDevice.TorchMode.on ? .off : .on
                device?.unlockForConfiguration()
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    @IBAction func addPdfFile(_ sender: UIButton) {
        var documentPickerController: UIDocumentPickerViewController!
        documentPickerController = UIDocumentPickerViewController(documentTypes: ["com.adobe.pdf", /*"public.image"*/"public.composite-content"], in: .import)
        documentPickerController.delegate = self
        present(documentPickerController, animated: true, completion: nil)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        let image = drawPDFfromURL(url: url)
        let qrString = string(from: image!)
        let a = qrString.components(separatedBy: "|")

        a.forEach { [weak self] v in
            if v.contains("qr.nspk.ru") {
                onC2B(link: v)
                return
            }
            if v.contains("=") {
                let tempArray = v.components(separatedBy: "=")
                var key = tempArray[0].lowercased()
                let value = tempArray[1]
                if key == "persacc" {
                    key = "Лицевой счет"
                }
                if key == "sum" {
                    key = "Сумма"
                }
                self?.qrData.updateValue(value, forKey: key)
            }
        }

        let inn = qrData.filter {
            $0.key == "payeeinn"
        }
        if inn != [:] {
            operatorsList?.forEach({ operators in
                if operators.synonymList.first == inn.values.first {
                    self.operators = operators
                }
            })
            returnKey()
        } else {
            performSegue(withIdentifier: "qrError", sender: nil)
        }
    }

    final func onC2B(link: String) {
        qrCodesession.stopRunning()
        qrView.layer.sublayers?.removeLast()
        GlobalModule.c2bURL = link
        dismiss(animated: false)
    }

    final func returnKey() {
        qrCodesession.stopRunning()
        qrView.layer.sublayers?.removeLast()
        if operators != nil {
            GlobalModule.qrOperator = operators
            GlobalModule.qrData = qrData
            dismiss(animated: false)
            //navigationController?.popViewController(animated: true)
        } else {
            performSegue(withIdentifier: "qrError", sender: nil)
        }
    }

    @IBAction func back(_ sender: UIButton) {
        qrCodesession.stopRunning()
        qrView.layer.sublayers?.removeLast()
        dismiss(animated: false)
        //navigationController?.popViewController(animated: true)
    }
}
