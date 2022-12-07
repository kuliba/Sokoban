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

//MARK: - View Model

extension QRScannerView {
    
    class ViewModel {
        
        let action: PassthroughSubject<Action, Never> = .init()
    }
}

//MARK: - View

struct QRScannerView: UIViewControllerRepresentable {
    
    let viewModel: ViewModel
    
    func makeUIViewController(context: Context) -> QRScannerViewController {
        QRScannerViewController(viewModel: viewModel)
    }
    
    func updateUIViewController(_ uiViewController: QRScannerViewController, context: Context) {}
}

//MARK: - Action

enum QRScannerViewAction {
    
    struct Scanned: Action {
        
        let value: String
    }
    
    struct Fail: Action {
        
        let error: QRScannerViewModelError
    }
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
            self.viewModel.action.send(QRScannerViewAction.Fail(error: .unableCreateVideoCaptureDevice))
            return
        }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            
        } catch {
            self.viewModel.action.send(QRScannerViewAction.Fail(error: .unableCreateVideoInput))
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
            
        } else {
            self.viewModel.action.send(QRScannerViewAction.Fail(error: .unableAddVideoInputToCaptureSession))
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
        } else {
            self.viewModel.action.send(QRScannerViewAction.Fail(error: .unableAddMetadataOutputToCaptureSession))
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
            return
        }
        
        self.viewModel.action.send(QRScannerViewAction.Scanned(value: stringValue))
        captureSession?.stopRunning()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

//MARK: - Error

enum QRScannerViewModelError: Error {
    
    case unableCreateVideoCaptureDevice
    case unableCreateVideoInput
    case unableAddVideoInputToCaptureSession
    case unableAddMetadataOutputToCaptureSession
}
