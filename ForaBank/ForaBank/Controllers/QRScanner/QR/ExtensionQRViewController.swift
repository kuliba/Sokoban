//
//  ExtensionQRViewController.swift
//  ForaBank
//
//  Created by Константин Савялов on 03.09.2021.
//

import UIKit
import AVFoundation
import RealmSwift

extension QRViewController {
    
    
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
