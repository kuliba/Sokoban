//
//  QRViewController.swift
//  ForaBank
//
//  Created by Константин Савялов on 18.08.2021.
//

import UIKit
import AVFoundation

import PDFKit
import MobileCoreServices
import UniformTypeIdentifiers
import Combine


protocol QRProtocol: AnyObject {
    func setResultOfBusinessLogic (_ qr: [String: String], _ model: GKHOperatorsModel )
}

final class QRViewController: BottomPopUpViewAdapter, UIDocumentPickerDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    public static func storyboardInstance() -> QRViewController? {
            let storyboard = UIStoryboard(name: "QRCodeStoryboard", bundle: nil)
            return storyboard.instantiateViewController(withIdentifier: "qr") as? QRViewController
        }
    
    var viewModel: QRViewModel?
    weak var delegate: QRProtocol?
    var qrCodeLayer = AVCaptureVideoPreviewLayer()
    let qrCodesession = AVCaptureSession()
    var alertController: UIAlertController?
    
    @IBOutlet weak var pdfFile: UIButton!
    @IBOutlet weak var zap: UIButton!
    @IBOutlet weak var info: UIButton!

    let bottomSpace: CGFloat = 80.0
    var squareView: SquareView? = nil
    var operatorsList: [GKHOperatorsModel]? = nil
    var keyValue = ""
    var qrData = [String: String]()
    var operators: GKHOperatorsModel? = nil
    var qrIsFired = false
    var segueOut = true
    var imagePicker: UIImagePickerController!

    @IBOutlet weak var qrView: UIView!
    @IBOutlet weak var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pdfFile.add_CornerRadius(30)
        zap.add_CornerRadius(30)
        info.add_CornerRadius(30)
        
        operatorsList = getOperatorsList(model: Model.shared)
        setupLayer()
        startQRCodeScanning()
        view.insertSubview(qrView, at: 1)
        backButton.setupButtonRadius()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.layer.zPosition = -1
    }
    
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true)
    }
    
    func getOperatorsList(model: Model) -> [GKHOperatorsModel] {
        
        let operators = (model.dictionaryAnywayOperatorGroups()?.compactMap { $0.returnOperators() }) ?? []
        let operatorCodes = [GlobalModule.UTILITIES_CODE, GlobalModule.INTERNET_TV_CODE, GlobalModule.PAYMENT_TRANSPORT]
        let parameterTypes = ["INPUT"]
        let operatorsList = GKHOperatorsModel.childOperators(with: operators, operatorCodes: operatorCodes, parameterTypes: parameterTypes)
        return operatorsList
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
                break
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
                self?.onC2B(link: v, getUImage: self?.viewModel?.getUImage ?? { _ in UIImage()})
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
            
            let storyboard = UIStoryboard(name: "QRCodeStoryboard", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "qrError") as? QRErrorViewController {
            //    viewModel?.closeAction(false)
                self.present(vc, animated: true)
            }
        }
    }

    final func onC2B(link: String, getUImage: @escaping (Md5hash) -> UIImage?) {
        qrCodesession.stopRunning()
        GlobalModule.c2bURL = link
       // viewModel?.closeAction(false)
        navigationController?.popViewController(animated: true)
        self.presentingViewController?.dismiss(animated: true, completion: nil)
        
        if GlobalModule.c2bURL != nil,  let controller = C2BDetailsViewController.storyboardInstance() {
            controller.getUImage = getUImage
            let nc = UINavigationController(rootViewController: controller)
            nc.modalPresentationStyle = .fullScreen
            present(nc, animated: false)
        }
    }

    final func returnKey() {
        qrCodesession.stopRunning()

        if operators != nil {
            GlobalModule.qrOperator = operators
            GlobalModule.qrData = qrData
            if viewModel != nil {
           //     viewModel?.closeAction(true)
            } else if segueOut == true {
                self.navigationController?.popViewController(animated: true)
            } else {
                self.dismiss(animated: true)
            }
            
            
//            GlobalModule.qrOperator = operators
//            GlobalModule.qrData = qrData
//            self.definesPresentationContext = true
//            navigationController?.popViewController(animated: true)
////            self.presentingViewController?.dismiss(animated: true, completion: nil)
//            self.tabBarController?.tabBar.layer.zPosition = 0
//            navigationController?.isNavigationBarHidden = false

//            if GlobalModule.qrOperator != nil && GlobalModule.qrData != nil, let controller = InternetTVMainController.storyboardInstance() {
//                    let nc = UINavigationController(rootViewController: controller)
//                    nc.modalPresentationStyle = .fullScreen
//                    present(nc, animated: false)
//            }
            
        } else {

            let storyboard = UIStoryboard(name: "QRCodeStoryboard", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "qrError") as? QRErrorViewController {
                self.present(vc, animated: true)
            }
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        
        qrCodesession.stopRunning()
        if viewModel != nil {
        //    viewModel?.closeAction(false)
        } else if segueOut == true {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true)
        }

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
                
                let storyboard = UIStoryboard(name: "QRCodeStoryboard", bundle: nil)
                if let vc = storyboard.instantiateViewController(withIdentifier: "qrError") as? QRErrorViewController {
               //     self?.viewModel?.closeAction(false)
                    self?.present(vc, animated: true)
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.tabBarController?.tabBar.layer.zPosition = 0
        navigationController?.isNavigationBarHidden = true
    }

}
