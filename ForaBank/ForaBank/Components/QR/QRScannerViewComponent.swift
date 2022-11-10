//
//  QRScannerView.swift
//  ForaBank
//
//  Created by Константин Савялов on 21.10.2022.
//

import AVFoundation
import UIKit
import SwiftUI
import Combine

struct QRScannerView: UIViewControllerRepresentable {
    
    @ObservedObject var viewModel: ViewModel
    
    func makeUIViewController(context: Context) -> QRScannerViewController {
        QRScannerViewController(viewModel: viewModel)
    }
    
    func updateUIViewController(_ uiViewController: QRScannerViewController, context: Context) {}
}

extension QRScannerView {
    
    class ViewModel: ObservableObject {
        
        let action: PassthroughSubject<Action, Never> = .init()
    }
}

extension QRScannerView {
    
    enum Response: Action {
        
        case success(String)
        case failure
    }
}

enum QRScannerViewModelError: Error {
    
    case unableCreateVideoCaptureDevice
    case unableCreateVideoInput
    case unableAddVideoInputToCaptureSession
    case unableAddMetadataOutputToCaptureSession
}

class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    let viewModel: QRScannerView.ViewModel
    
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    init(viewModel: QRScannerView.ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            // unableCreateVideoCaptureDevice
            return
        }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            
        } catch {
            // unableCreateVideoInput
            
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
            
        } else {
            // unableAddVideoInputToCaptureSession
           
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
        } else {
            // unableAddMetadataOutputToCaptureSession
            
            return
        }
        
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = [.qr, .aztec]
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.backgroundColor = UIColor.black
        view.layer.addSublayer(previewLayer)
        
        self.captureSession = captureSession
        self.previewLayer = previewLayer
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession?.isRunning == false) {
                self.captureSession?.startRunning()
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        guard let metadataObject = metadataObjects.first,
              let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
              let stringValue = readableObject.stringValue
              else {
                   self.viewModel.action.send(QRScannerView.Response.failure)
                   return
        }
        
        self.viewModel.action.send(QRScannerView.Response.success(stringValue))
        captureSession?.stopRunning()
        
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

