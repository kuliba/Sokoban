//
//  QRViewController.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 29.06.2020.
//  Copyright © 2020 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import AVFoundation
import UIKit

struct QRCodeData : Decodable {
    let Name,PersonalAcc,BankName, BIC, CorrespACC, PayeeINN, Category, PersACC, LastName, FirstName, MiddleName, PayerAddress,Sum, PaymPeriod:String
}

protocol DataEnteredDelegate: class {
    func userDidEnterInformation(array: [String])
}

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, ScanDelegate {
   
    
    weak var delegate: DataEnteredDelegate?

    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!

   
    
    var scanDelegate: ScanDelegate?

    
    @IBOutlet var cameraView: UIView!
    
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true, completion: {
            let vc = OperationDetailViewController()
            vc.scanDelegate = self
            self.present(vc, animated: true, completion: nil)
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }
      
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        cameraView.layer.addSublayer(previewLayer)
     
       
        

        captureSession.startRunning()
    }

   
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        scanDelegate?.passString(scandata: "someData")

        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        if metadataObjects != nil && metadataObjects.count != 0
         {
             let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject

                 if metadataObj.type == AVMetadataObject.ObjectType.qr
                 {
                    guard let stringValue = metadataObj.stringValue else { return }
                    if let res = try? JSONSerialization.jsonObject(with:Data(stringValue.utf8), options: []) as? [String:String]{
                        let fin = res
                        guard let number = fin["BankName"]  else { return }
                        print(number)
                    }
                    if let res = try? JSONDecoder().decode(QRCodeData.self, from: Data(stringValue.utf8)) {
                        print(res.Sum)
                    }
                 }
         }
        if let metadataObject = metadataObjects.first {
//            let metadataObject as? AVCaptureMetadataOutput()
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            let test = stringValue
            let data = test.data(using: .utf8)!
//            guard let qrCodeData = metadataObject else { return }
            if let metadataObject = metadataObjects.first {
                      guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                      guard let stringValue = readableObject.stringValue else { return }
                      AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
//                      found(code: stringValue)
//                guard let stringValue = stringValuee else { return }
            
                  }
//            if let res = try? JSONDecoder().decode(QRCodeData.self, from: Data(test.utf8)) {
//                print(res.Sum)
//            }
            do{
                let output = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:String]
                print ("\(String(describing: output))")
         
            }
            catch {
                print (error)
            }
            
            
            let string = stringValue
            
            let array = string.components(separatedBy: "=")
            print(stringValue)
            print(array) // returns ["1", "2", "3"]
            _ = array.reduce(into: [String: Any]()) { $0[$1] =   string.components(separatedBy: "=") }
            var cleanArray = ["Sring"]
            for i in array {
                let cleanString = i.components(separatedBy: "|")
                cleanArray.append(cleanString[0])
            }
            cleanArray.removeFirst()
            cleanArray.removeFirst()
        
//            if cleanArray.count == 11{
//                         let alert = UIAlertController(title: "Вы отсканировани QR коде для перевода Юридическому лицу", message: "", preferredStyle: .alert)
//                         let passAction = UIAlertAction(title: "Pereit", style: .default) { (alert) in
//
//                            if #available(iOS 13.0, *) {
//                                let storyboard = UIStoryboard(name: "Payment", bundle: nil)
//                                let freePayment = storyboard.instantiateViewController(identifier: "FreeDetailsController") as? FreeDetailsViewController
//                                 self.present(freePayment!, animated: true, completion: nil)
//                            } else {
//                                // Fallback on earlier versions
//                            }
//
//                         }
//                         alert.addAction(passAction)
//                         present(alert, animated: true, completion: nil)
//            } else{
//            delegate?.userDidEnterInformation(array: cleanArray)
//
//            dismiss(animated: true, completion: {
//                let vc = OperationDetailViewController()
//                vc.arrayData = array
//                  })
//            }
            
            
            delegate?.userDidEnterInformation(array: cleanArray)

                      dismiss(animated: true, completion: {
                          let vc = OperationDetailViewController()
                          vc.arrayData = array
                            })
        }

    }
    func passString(scandata: String) {
              
    }


    
 
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
