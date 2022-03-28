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
import MobileCoreServices
import UniformTypeIdentifiers


protocol QRProtocol: AnyObject {
    func setResultOfBusinessLogic (_ qr: [String: String], _ model: GKHOperatorsModel )
}

final class QRViewController: BottomPopUpViewAdapter, UIDocumentPickerDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    public static func storyboardInstance() -> QRViewController? {
            let storyboard = UIStoryboard(name: "QRCodeStoryboard", bundle: nil)
            return storyboard.instantiateViewController(withIdentifier: "qr") as? QRViewController
        }
    
    weak var delegate: QRProtocol?
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

    var imagePicker: UIImagePickerController!

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

        let controller = QRSearchDataViewController()
        controller.itemIsSelect = { [weak self] item in

            switch item {
            case "Из Фото":
                self?.showImagePicker()
            case "Из Документов":
                var documentPickerController: UIDocumentPickerViewController!
                documentPickerController = UIDocumentPickerViewController(documentTypes: ["com.adobe.pdf", "public.composite-content"], in: .import)
                documentPickerController.delegate = self
                self?.present(documentPickerController, animated: true, completion: nil)
            default:
                print()
            }


        }

        let navController = UINavigationController(rootViewController: controller)
        navController.modalPresentationStyle = .custom
        navController.transitioningDelegate = self
        self.present(navController, animated: true)

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
                    self?.qrData.updateValue(value, forKey: key)
                }
                if key == "sum" {
                    key = "Сумма"
                    self?.qrData.updateValue(value, forKey: key)
                }

                if key == "personalacc" {
                    key = "Pасчетный счет Получателя"
                    self?.qrData.updateValue(value, forKey: key)
                }

            }
        }
       
        let inn = qrData.filter { $0.key == "payeeinn" }
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
            self.definesPresentationContext = true
            dismiss(animated: false)
//            self.presentingViewController?.dismiss(animated: true, completion: nil)
//            navigationController?.popViewController(animated: true)
        } else {
            performSegue(withIdentifier: "qrError", sender: nil)
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        qrCodesession.stopRunning()
        qrView.layer.sublayers?.removeLast()
//        dismiss(animated: false)

        self.definesPresentationContext = true
        self.presentingViewController?.dismiss(animated: true, completion: nil)
//        navigationController?.popViewController(animated: true)
    }
}


extension QRViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presenter = PresentationController(presentedViewController: presented, presenting: presenting)
        presenter.height = 240
        return presenter
    }
}

extension QRViewController {

    func showImagePicker() {
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController,
      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true) { [weak self] in
            let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage

            let qrString = self?.string(from: image!)
            let a = qrString?.components(separatedBy: "|")

            a?.forEach { [weak self] v in
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

                    if key == "personalacc" {
                        key = "Pасчетный счет Получателя"
                        self?.qrData.updateValue(value, forKey: key)
                    }
                    self?.qrData.updateValue(value, forKey: key)
                }
            }

            let inn = self?.qrData.filter { $0.key == "payeeinn" }
            if inn != [:] {
                self?.operatorsList?.forEach({ operators in
                    if operators.synonymList.first == inn?.values.first {
                    self?.operators = operators
                }
            })
                self?.returnKey()
            } else {
                self?.performSegue(withIdentifier: "qrError", sender: nil)
            }
        }
    }

}
