//
//  QRViewModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 01.11.2022.
//

import Foundation
import Combine
import SwiftUI
import AVFoundation

class QRViewModel: ObservableObject {
    
    let action: PassthroughSubject<Action, Never> = .init()
    let scanner: QRScannerView.ViewModel
    let title: String
    let subTitle: String
    private let model: Model
    
    var flashLight: FlashLight = .on
    @Published var buttons: [ButtonIconTextView.ViewModel]
    @Published var clouseButton: ButtonSimpleView.ViewModel
    
    @Published var link: Link? { didSet { isLinkActive = link != nil } }
    @Published var isLinkActive: Bool = false
    @Published var bottomSheet: BottomSheet?
    @Published var sheet: Sheet?
    @Published var alert: Alert.ViewModel?
    
    private var bindings = Set<AnyCancellable>()
    
    
    init(scanner: QRScannerView.ViewModel, title: String, subTitle: String, buttons: [ButtonIconTextView.ViewModel], clouseButton: ButtonSimpleView.ViewModel, model: Model) {
        self.scanner = scanner
        self.title = title
        self.subTitle = subTitle
        self.buttons = buttons
        self.clouseButton = clouseButton
        self.model = model
    }
    
    convenience init(closeAction: @escaping () -> Void) {
        
        let clouseButton = ButtonSimpleView.ViewModel(title: "Отмена", style: .gray, action: closeAction)
        
        self.init(scanner: QRScannerView.ViewModel(), title: "Наведите камеру", subTitle: "на QR-код", buttons: [], clouseButton: clouseButton, model: Model.shared)
        
        self.buttons = createButtons()
        
        bind()
        cameraAccess()
    }
    
    func bind() {
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                switch action {
                    
                case _ as QRViewModelAction.OpenDocument:
                    self.bottomSheet = .init(sheetType: .choiseDocument(.init(buttons: [
                        .init(icon: .init(image: .ic24Camera, background: .circle), title: .init(text: "Из фото", style: .bold), orientation: .horizontal, action: { [weak self] in
                            self?.bottomSheet = nil
                            self?.model.action.send(ModelAction.Media.GalleryPermission.Request())
                        }),
                        .init(icon: .init(image: .ic24FileText, background: .circle), title: .init(text: "Из Документов", style: .bold), orientation: .horizontal, action: { [weak self] in
                            self?.model.action.send(ModelAction.Media.DocumentPermission.Request())
                        })
                    ])))
                    
                case _ as QRViewModelAction.Info:
                    self.bottomSheet = .init(sheetType: .info(.init(viewModel: .init(icon: .ic24AlertCircle,
                                                                                     title: "Сканировать QR-код",
                                                                                     content: "Наведите камеру телефона на QR-код, и приложение автоматически его считает.\n\n Перед оплатой проверьте, что все поля заполнены правильно.\n\n Чтобы оплатить квитанцию, сохраненнуюв телефоне, откройте ее с помощью кнопки \"Из файла\", и отсканируйте QR-код."))) )
                    
                case _ as QRViewModelAction.AccessCamera:
                    
                    self.bottomSheet = .init(sheetType: .qRAccessViewComponent(.init(viewModel: .init(input: .camera, closeAction: {[weak self] in
                        self?.sheet = nil
                    }))))
                    
                case _ as QRViewModelAction.AccessPhotoGallery:
                    
                    self.bottomSheet = .init(sheetType: .photoAccessViewComponent(.init(viewModel: .init(input: .photo, closeAction: {[weak self] in
                        self?.sheet = nil
                    }))))
                    
                case _ as QRViewModelAction.Flashlight:
                    
                    self.flashLightTorch(on: self.flashLight.result.0)
                    
                case _ as QRViewModelAction.CloseLink:
                    link = nil
                    
                case _ as QRViewModelAction.CloseBottomSheet:
                    withAnimation {
                        
                        self.bottomSheet = nil
                    }
                case _ as QRViewModelAction.CloseSheet:
                    sheet = nil
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                    
                case let payload as ModelAction.Media.GalleryPermission.Response:
                    
                    self.action.send(QRViewModelAction.CloseBottomSheet())
                    
                    if payload.result {
                        
                        let imagePicker = ImagePickerControllerViewModel { [weak self] image in
                            
                            if let qrData = self?.string(from: image) {
                                
                                let result = Self.resolve(data: qrData)
                                
                                self?.action.send(QRViewModelAction.Result(result: result))
                            }
                            
                            self?.action.send(QRViewModelAction.CloseSheet())
                            
                        } closeAction: { [weak self] in
                            
                            self?.action.send(QRViewModelAction.CloseSheet())
                        }
                        
                        self.sheet = .init(sheetType: .imagePicker(imagePicker))
                        
                    } else {
                        self.action.send(QRViewModelAction.AccessPhotoGallery())
                    }
                    
                case _ as ModelAction.Media.DocumentPermission.Response:
                    
                    self.action.send(QRViewModelAction.CloseBottomSheet())
                    
                    let documentPicker = DocumentPickerViewModel { [weak self] url in
                        
                        if let image = self?.qrFromPDF(path: url),
                           let qrData = self?.string(from: image) {
                            
                            let result = Self.resolve(data: qrData)
                            
                            self?.action.send(QRViewModelAction.Result(result: result))
                            
                        } else {
                            
                            
                        }
                        
                        self?.action.send(QRViewModelAction.CloseSheet())
                        
                    } closeAction: { [weak self] in
                        
                        self?.action.send(QRViewModelAction.CloseSheet())
                    }
                    
                    self.sheet = .init(sheetType: .documentPicker(documentPicker))
                    
                default:
                    break
                }
            }.store(in: &bindings)
        
        scanner.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as QRScannerViewAction.Scanned:
                    let result = Self.resolve(data: payload.value)
                    
                    self.action.send(QRViewModelAction.Result(result: result))
                    
                default:
                    break
                }
            } .store(in: &bindings)
    }
}

//MARK: - Types

extension QRViewModel {
    
    struct BottomSheet: Identifiable {
        
        let id = UUID()
        let sheetType: SheetType
        
        enum SheetType {
            
            case imageCapture(ImagePickerControllerViewModel)
            case info(QRInfoViewComponent)
            case choiseDocument(QRButtonsView.ViewModel)
            case qRAccessViewComponent(QRAccessViewComponent)
            case photoAccessViewComponent(QRAccessViewComponent)
        }
    }
    
    struct Sheet: Identifiable {
        
        let id = UUID()
        let sheetType: SheetType
        
        enum SheetType {
            
            case imagePicker(ImagePickerControllerViewModel)
            case documentPicker(DocumentPickerViewModel)
        }
    }
    
    enum Link {
        
        case failedView(QRFailedViewModel)
    }
    
    enum Result {
        
        case qrCode(QRCode)
        case c2bURL(URL)
        case url(URL)
        case unknown(String)
    }
}

//MARK: - Resovers

extension QRViewModel {
    
    //TODO: tests
    static func resolve(data: String) -> Result {
        
        if let url = URL(string: data) {
            
            if url.absoluteString.contains("qr.nspk.ru") {
                
                return .c2bURL(url)
                
            } else {
                
                return .url(url)
            }
            
        } else if let qrCode = QRCode(string: data) {
            
            return .qrCode(qrCode)
            
        } else {
            
            return .unknown(data)
        }
    }
    
    func qrFromPDF(path: URL) -> UIImage? {
        
        guard let document = CGPDFDocument(path as CFURL) else { return nil }
        
        var width: CGFloat = 0
        var height: CGFloat = 0
        
        // calculating overall page size
        for index in 1...document.numberOfPages {
            if let page = document.page(at: index) {
                let pageRect = page.getBoxRect(.mediaBox)
                width = max(width, pageRect.width)
                height = height + pageRect.height
            }
        }
        
        // now creating the image
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height))
        
        let image = renderer.image { (ctx) in
            ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
            for index in 1...document.numberOfPages {
                
                if let page = document.page(at: index) {
                    let pageRect = page.getBoxRect(.mediaBox)
                    ctx.cgContext.translateBy(x: 0.0, y: -pageRect.height)
                    ctx.cgContext.drawPDFPage(page)
                }
            }
            
            ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
        }
        return image
    }
}

//MARK: - Helpers

extension QRViewModel {
    
    enum FlashLight {
        
        case on
        case off
        
        var result: (Bool, Image) {
            switch self {
            case .on: return (true, Image.ic24ZapOff)
            case .off: return (false, Image.ic24Zap)
            }
        }
    }
    
    func flashLightTorch(on: Bool) {
        
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                
                if on == true {
                    device.torchMode = .on
                    self.flashLight = .off
                } else {
                    device.torchMode = .off
                    self.flashLight = .on
                }
                
                self.buttons = createButtons()
                
                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        } else {
            print("Torch is not available")
        }
    }
    
    func cameraAccess() {
        
        if model.cameraAgent.isCameraAvailable {
            model.cameraAgent.requestPermissions(completion: {[weak self] available in
                
                if !available {
                    self?.action.send(QRViewModelAction.AccessCamera())
                }
            })
        }
    }
    func createButtons() -> [ButtonIconTextView.ViewModel] {
        
        return [
            ButtonIconTextView.ViewModel(icon: .init(image: .ic24Image, background: .circle), title: .init(text: "Из файла", color: .white), orientation: .vertical, action: { [weak self] in
                self?.action.send(QRViewModelAction.OpenDocument())
            }),
            ButtonIconTextView.ViewModel(icon: .init(image: self.flashLight.result.1, background: .circle), title: .init(text: "Фонарик", color: .white), orientation: .vertical, action: { [weak self] in
                self?.action.send(QRViewModelAction.Flashlight())
            }),
            ButtonIconTextView.ViewModel(icon: .init(image: .ic24AlertCircle, background: .circle), title: .init(text: "Инфо", color: .white), orientation: .vertical, action: { [weak self] in
                self?.action.send(QRViewModelAction.Info())
            })]
    }
    
    func string(from image: UIImage) -> String {
        
        var qrAsString = ""
        guard let detector = CIDetector(ofType: CIDetectorTypeQRCode,
                                        context: nil,
                                        options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]),
              let ciImage = CIImage(image: image),
              let features = detector.features(in: ciImage) as? [CIQRCodeFeature] else {
            return qrAsString
        }
        
        for feature in features {
            guard let indeedMessageString = feature.messageString else {
                continue
            }
            qrAsString += indeedMessageString
        }
        return qrAsString
    }
    
    func flashlight() throws {
        let device = AVCaptureDevice.default(for: .video)
        if ((device?.hasTorch) != nil) {
            do {
                try device?.lockForConfiguration()
                device?.torchMode = device?.torchMode == AVCaptureDevice.TorchMode.on ? .off : .on
                device?.unlockForConfiguration()
            }
        }
    }
}

enum QRViewModelAction {
    
    struct OpenDocument: Action {}
    struct Info: Action {}
    struct AccessCamera: Action {}
    struct AccessPhotoGallery: Action {}
    struct Flashlight: Action {}
    struct Result: Action {
        
        let result: QRViewModel.Result
    }
    struct CloseLink: Action {}
    struct CloseBottomSheet: Action {}
    struct CloseSheet: Action {}
}
