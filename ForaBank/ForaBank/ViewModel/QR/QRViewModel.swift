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
    let getUImage: (Md5hash) -> UIImage?
    private let model: Model
    
    var flashLight: FlashLight = .on
    @Published var buttons: [ButtonIconTextView.ViewModel]
    @Published var closeButton: ButtonSimpleView.ViewModel
    
    @Published var link: Link? { didSet { isLinkActive = link != nil } }
    @Published var isLinkActive: Bool = false
    @Published var bottomSheet: BottomSheet?
    @Published var sheet: Sheet?
    @Published var alert: Alert.ViewModel?
    
    private var bindings = Set<AnyCancellable>()
    
    init(
        scanner: QRScannerView.ViewModel,
        title: String,
        subTitle: String,
        buttons: [ButtonIconTextView.ViewModel],
        closeButton: ButtonSimpleView.ViewModel,
        model: Model
    ) {
        self.scanner = scanner
        self.title = title
        self.subTitle = subTitle
        self.buttons = buttons
        self.closeButton = closeButton
        self.model = model
        self.getUImage = { model.images.value[$0]?.uiImage }
    }
    
    typealias QRResolve = (String) -> ScanResult
    
    convenience init(
        closeAction: @escaping () -> Void,
        qrResolve: @escaping QRResolve
    ) {
        let closeButton = ButtonSimpleView.ViewModel(
            title: "Отмена",
            style: .gray,
            action: closeAction
        )
        
        self.init(
            scanner: QRScannerView.ViewModel(),
            title: "Наведите камеру",
            subTitle: "на QR-код",
            buttons: [],
            closeButton: closeButton,
            model: Model.shared
        )
        
        self.buttons = createButtons()
        
        bind(qrResolve: qrResolve)
        cameraAccess()
    }
    
    func bind(qrResolve: @escaping QRResolve) {
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in handleAction($0) }
            .store(in: &bindings)
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                handleModelAction(action, qrResolve: qrResolve )
            }
            .store(in: &bindings)
        
        scanner.action
            .compactMap { $0 as? QRScannerViewAction.Scanned }
            .map(\.value)
            .map(qrResolve)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in self.handleScanResult($0) }
            .store(in: &bindings)
    }
}

// MARK: - Helpers

private extension QRViewModel {
    
    func handleAction(
        _ action: any Action
    ) {
        switch action {
        case _ as QRViewModelAction.OpenDocument:
            self.openDocument()
            
        case _ as QRViewModelAction.Info:
            self.openInfo()
            
        case _ as QRViewModelAction.AccessCamera:
            DispatchQueue.main.delay(for: .milliseconds(700)) {
                
                self.accessCamera()
            }
            
        case _ as QRViewModelAction.AccessPhotoGallery:
            self.accessPhotoGallery()
            
        case _ as QRViewModelAction.Flashlight:
            self.flashLightTorch(on: self.flashLight.result.0)
            
        case _ as QRViewModelAction.CloseLink:
            link = nil
            
        case _ as QRViewModelAction.CloseBottomSheet:
            self.bottomSheet = nil
            
        case _ as QRViewModelAction.CloseSheet:
            sheet = nil
            
        default:
            break
        }
    }

    func openDocument() {
        
        bottomSheet = .init(
            sheetType: .choiseDocument(.init(
                buttons: [
                    .init(
                        icon: .init(image: .ic24Image, background: .circle),
                        title: .init(text: "Из фото", style: .bold),
                        orientation: .horizontal, action: { [weak self] in
                            
                            self?.bottomSheet = nil
                            self?.model.action.send(ModelAction.Media.GalleryPermission.Request())
                        }
                    ),
                    .init(
                        icon: .init(image: .ic24FileText, background: .circle),
                        title: .init(text: "Из Документов", style: .bold),
                        orientation: .horizontal,
                        action: { [weak self] in
                            
                            self?.model.action.send(ModelAction.Media.DocumentPermission.Request())
                        }
                    )
                ]
            ))
        )
    }
    
    func openInfo() {
        
        bottomSheet = .init(
            sheetType: .info(.init(
                icon: .ic48Info,
                title: "Сканировать QR-код",
                content: ["\tНаведите камеру телефона на QR-код,\n и приложение автоматически его считает.",
                          "\tПеред оплатой проверьте, что все поля заполнены правильно.",
                          "\tЧтобы оплатить квитанцию, сохраненную в телефоне, откройте ее с помощью кнопки \"Из файла\" и отсканируйте QR-код."]
            ))
        )
    }
    
    func accessCamera() {
        
        bottomSheet = .init(
            sheetType: .qRAccessViewComponent(.init(
                viewModel: .init(
                    input: .camera,
                    closeAction: { [weak self] in self?.sheet = nil }
                )
            ))
        )
    }
    
    func accessPhotoGallery() {
        
        bottomSheet = .init(
            sheetType: .photoAccessViewComponent(.init(
                viewModel: .init(
                    input: .photo,
                    closeAction: { [weak self] in self?.sheet = nil }
                )
            ))
        )
    }
    
    func handleModelAction(
        _ action: any Action,
        qrResolve: @escaping QRResolve
    ) {
        switch action {
        case let payload as ModelAction.Media.GalleryPermission.Response:
            self.handleGalleryPermission(
                response: payload,
                qrResolve: qrResolve
            )
            
        case _ as ModelAction.Media.DocumentPermission.Response:
            self.handleDocumentPermission(qrResolve: qrResolve)
            
        default:
            break
        }

    }
    
    func handleGalleryPermission(
        response: ModelAction.Media.GalleryPermission.Response,
        qrResolve: @escaping QRResolve
    ) {
        action.send(QRViewModelAction.CloseBottomSheet())
        
        if response.result {
            
            let imagePicker = ImagePickerControllerViewModel { [weak self] image in
                
                if let qrData = self?.string(from: image) {
                    
                    let result = qrResolve(qrData)
                    
                    self?.action.send(QRViewModelAction.Result(result: result))
                }
                
                self?.action.send(QRViewModelAction.CloseSheet())
                
            } closeAction: { [weak self] in
                
                self?.action.send(QRViewModelAction.CloseSheet())
            }
            
            DispatchQueue.main.delay(for: .milliseconds(400)) { [weak self] in
                
                self?.sheet = .init(sheetType: .imagePicker(imagePicker))
            }
            
        } else {
            
            self.action.send(QRViewModelAction.AccessPhotoGallery())
        }
    }
    
    func handleDocumentPermission(
        qrResolve: @escaping QRResolve
    ) {
        action.send(QRViewModelAction.CloseBottomSheet())
        
        let documentPicker = DocumentPickerViewModel { [weak self] url in
            
            if let image = self?.qrFromPDF(path: url),
               let qrData = self?.string(from: image) {
                
                let result = qrResolve(qrData)
                
                self?.action.send(QRViewModelAction.Result(result: result))
                
            } else {
                
                self?.action.send(QRViewModelAction.Result(result: .unknown))
                
            }
            
            self?.action.send(QRViewModelAction.CloseSheet())
            
        } closeAction: { [weak self] in
            
            self?.action.send(QRViewModelAction.CloseSheet())
        }
        
        self.sheet = .init(sheetType: .documentPicker(documentPicker))
    }
    
    func handleScanResult(
        _ result: QRViewModel.ScanResult
    ) {
        action.send(QRViewModelAction.Result(result: result))
        
        if case let .qrCode(qrCode) = result,
           let mapping = model.qrMapping.value,
           let failData = qrCode.check(mapping: mapping) {
            
            model.action.send(ModelAction.QRAction.SendFailData.Request(failData: failData))
        }
    }
}

//MARK: - Types

extension QRViewModel {
    
    struct BottomSheet: BottomSheetCustomizable {
        
        let id = UUID()
        let sheetType: SheetType
        
        enum SheetType {
            
            case imageCapture(ImagePickerControllerViewModel)
            case info(QRInfoViewModel.ViewModel)
            case choiseDocument(QRButtonsView.ViewModel)
            case qRAccessViewComponent(QRAccessView)
            case photoAccessViewComponent(QRAccessView)
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
    
    enum ScanResult {
        
        case qrCode(QRCode)
        case c2bURL(URL)
        case c2bSubscribeURL(URL)
        case sberQR(URL)
        case url(URL)
        case unknown
    }
}

// MARK: - Resolvers

extension QRViewModel.ScanResult {
    
    // TODO: add tests
    init(string: String) {
        
        if let url = URL(string: string) {
            
            if url.absoluteString.contains("qr.nspk.ru") {
                
                self = .c2bURL(url)
                
            } else if url.absoluteString.contains("sub.nspk.ru") {
                
                self = .c2bSubscribeURL(url)
                
            } else {
                
                self = .url(url)
            }
            
        } else if let qrCode = QRCode(string: string) {
            
            self = .qrCode(qrCode)
            
        } else {
            
            self = .unknown
        }
    }
}

extension QRViewModel {
    
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
            case .on: return (true, Image.ic24Zap)
            case .off: return (false, Image.ic24ZapOff)
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
        
        let result: QRViewModel.ScanResult
    }
    struct CloseLink: Action {}
    struct CloseBottomSheet: Action {}
    struct CloseSheet: Action {}
}
