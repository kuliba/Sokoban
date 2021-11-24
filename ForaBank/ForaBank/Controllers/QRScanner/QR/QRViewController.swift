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
    func setResultOfBusinessLogic (_ qr: [String: String], _ model: GKHOperatorsModel )
}

final class QRViewController: BottomPopUpViewAdapter, UIDocumentPickerDelegate {
    
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
    
    @IBOutlet weak var qrView: UIView!
    @IBOutlet weak var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pdfFile.add_CornerRadius(30)
        zap.add_CornerRadius(30)
        info.add_CornerRadius(30)
        self.navigationController?.isNavigationBarHidden = true
        
        operatorsList = realm?.objects(GKHOperatorsModel.self)
        self.setupLayer()
        self.startQRCodeScanning()
        self.view.insertSubview(qrView, at: 1)
        self.backButton.setupButtonRadius()
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
       
        let inn = qrData.filter { $0.key == "payeeinn" }
        if inn != [:] {
        operatorsList?.forEach({ operators in
            if operators.synonymList.first == inn.values.first {
                self.operators = operators
            }
        })
        self.returnKey()
        } else {
            performSegue(withIdentifier: "qrError", sender: nil)
//            qrCoordinatorDelegate?.goToQRError()
        }
        
    }
    
    final func returnKey() {
        self.qrCodesession.stopRunning()
        self.qrView.layer.sublayers?.removeLast()
        if operators != nil {
//            self.qrCoordinatorDelegate?.goToExit()
            self.navigationController?.popViewController(animated: true)
            self.delegate?.setResultOfBusinessLogic(qrData, operators!)
        } else {
 //           qrCoordinatorDelegate?.goToQRError()
            performSegue(withIdentifier: "qrError", sender: nil)
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.qrCodesession.stopRunning()
        self.qrView.layer.sublayers?.removeLast()
//        self.qrCoordinatorDelegate?.goToExit()
        self.navigationController?.popViewController(animated: true)
        
    }
    
    deinit {
        print("QR Deinit")
    }
    
}
