//
//  QRViewController.swift
//  ForaBank
//
//  Created by Константин Савялов on 18.08.2021.
//

import UIKit
import AVFoundation
import RealmSwift

final class QRViewController: UIViewController {
    
    var qrCodeLayer = AVCaptureVideoPreviewLayer()
    let qrCodesession = AVCaptureSession()
    var alertController: UIAlertController?
    
    let bottomSpace: CGFloat = 80.0
    var squareView: SquareView? = nil
    
    lazy var realm = try? Realm()
    var operatorsList: Results<GKHOperatorsModel>? = nil
    
    var keyValue = ""
    var complition: ((String) -> ())?
    
    @IBOutlet weak var qrView: UIView!
    @IBOutlet weak var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        operatorsList = realm?.objects(GKHOperatorsModel.self)
        self.setupLayer()
        self.startQRCodeScanning()
        self.view.insertSubview(qrView, at: 1)
        self.backButton.setupButtonRadius()
    }
    
    
    final func returnKey() {
        self.complition?(self.keyValue)
        self.qrCodesession.stopRunning()
        self.qrView.layer.sublayers?.removeLast()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func back(_ sender: UIButton) {
        returnKey()
    }
    
}

extension QRViewController: AVCaptureMetadataOutputObjectsDelegate, CALayerDelegate {
    
    
    func setupLayer() {
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        let input: AVCaptureDeviceInput
        
        do {
            input = try AVCaptureDeviceInput(device: captureDevice)
            self.qrCodesession.addInput(input)
        } catch {
            return
        }
        
        let output = AVCaptureMetadataOutput()
        self.qrCodesession.addOutput(output)
        output.setMetadataObjectsDelegate(self, queue: .main)
        output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        
        self.qrCodeLayer = AVCaptureVideoPreviewLayer(session: qrCodesession)
        self.qrCodeLayer.videoGravity = .resizeAspectFill
        self.qrCodeLayer.frame = self.qrView.layer.frame
        self.qrView.backgroundColor = UIColor(white: 1, alpha: 1)
    }
    
    func startQRCodeScanning() {
        createCornerFrame()
        self.view.layer.insertSublayer(self.qrCodeLayer, at: 0)
        self.qrCodesession.startRunning()
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard metadataObjects.count > 0 else { return }
        if let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject {
            if object.type == AVMetadataObject.ObjectType.qr {
                self.keyValue = object.stringValue ?? ""
                let a = self.keyValue.components(separatedBy: "|")
                var c = [String: String?]()
                
                a.forEach { v in
                    let tempArray = v.components(separatedBy: "=")
                    print(tempArray)
//                    let key = tempArray[0]
//                    let value = tempArray[1]
//                    c.updateValue(value, forKey: key)
                }
                let r = c
                
          //      let b = operatorsList?.filter{ $0.synonymList.first == a }
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
    
    func createCornerFrame() {
                let width: CGFloat = 200.0
                let height: CGFloat = 200.0
                
                let rect = CGRect.init(
                    origin: CGPoint.init(
                        x: self.view.frame.midX - width/2,
                        y: self.view.frame.midY - (width + self.bottomSpace)/2),
                    size: CGSize.init(width: width, height: height))
                self.squareView = SquareView(frame: rect)
                if let squareView = squareView {
                    self.qrView.backgroundColor = UIColor.black.withAlphaComponent(0.5)

                    UIGraphicsBeginImageContext(self.qrView.bounds.size)
                    let cgContext = UIGraphicsGetCurrentContext()
                    cgContext?.setFillColor(UIColor.white.cgColor)
                    cgContext?.fill(self.qrView.bounds)
                    cgContext?.clear(CGRect(x: squareView.frame.origin.x + 2, y: squareView.frame.origin.y + 2, width: squareView.bounds.width - 4, height: squareView.frame.height - 4))
                    let maskImage = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()

                    let maskView = UIView(frame: self.qrView.bounds)
                    maskView.layer.contents = maskImage?.cgImage
                    self.qrView.mask = maskView
                    
                    squareView.autoresizingMask = UIView.AutoresizingMask(rawValue: UInt(0.0))
                    self.qrView.layer.masksToBounds = false
                    self.qrView.addSubview(squareView)
                    
        }
            }

}

