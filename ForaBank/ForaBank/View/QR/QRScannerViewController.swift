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
        
        var state: CurrentValueSubject<State, Never> = .init(.initialising)
        
        enum State {
            case initialising
            case ready
            case scanning
            case code(QRCode)
            case failed(QRScannerViewModelError)
        }
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
        
        viewModel.state.value = .initialising
        
        let captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            
            viewModel.state.value = .failed(.unableCreateVideoCaptureDevice)
            return
        }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            
        } catch {
            
            viewModel.state.value = .failed(.unableCreateVideoInput)
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
            
        } else {
            
            viewModel.state.value = .failed(.unableAddVideoInputToCaptureSession)
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
        } else {
            
            viewModel.state.value = .failed(.unableAddMetadataOutputToCaptureSession)
            return
        }
        
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = [.qr, .aztec]
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        view.backgroundColor = UIColor.black
        
        self.captureSession = captureSession
        self.previewLayer = previewLayer
        
        viewModel.state.value = .ready
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession?.isRunning == false) {
            DispatchQueue.main.async {
                self.viewModel.state.value = .scanning
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            self.viewModel.state.value = .ready
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        self.viewModel.state.value = .ready
        
        guard let metadataObject = metadataObjects.first else { return }
        guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
        guard let stringValue = readableObject.stringValue else { return }
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        guard let qrCode = QRCode(string: stringValue) else { return}
        self.viewModel.state.value = .code(qrCode)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

