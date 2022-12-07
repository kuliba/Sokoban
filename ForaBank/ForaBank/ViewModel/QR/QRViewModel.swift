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
    
    @Published var buttons: [ButtonIconTextView.ViewModel]
    @Published var clouseButton: ButtonSimpleView.ViewModel
    
    @Published var link: Link? { didSet { isLinkActive = link != nil } }
    @Published var isLinkActive: Bool = false
    @Published var bottomSheet: BottomSheet?
    @Published var alert: Alert.ViewModel?
    
    private let model: Model
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
    }
    
    func bind() {
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                switch action {
                    
                case _ as QRViewModelAction.OpenDocument:
                    self.bottomSheet = .init(sheetType: .choiseDocument(.init(buttons: [
                        .init(icon: .init(image: .ic24AlertCircle, background: .circle), title: .init(text: "Из фото", style: .bold), orientation: .horizontal, action: { [weak self] in
                            self?.bottomSheet = nil
                            self?.model.action.send(ModelAction.Media.GalleryPermission.Request())
                        }),
                        .init(icon: .init(image: .ic24Clock, background: .circle), title: .init(text: "Из Документов", style: .bold), orientation: .horizontal, action: { [weak self] in
                          self?.model.action.send(ModelAction.Media.DocumentPermission.Request())
                        })
                    ])))
                    
                case _ as QRViewModelAction.Info:
                    self.bottomSheet = .init(sheetType: .info(.init(viewModel: .init(icon: .ic24AlertCircle,
                                                                                     title: "Сканировать QR-код",
                                                                                     content: "Наведите камеру телефона на QR-код, и приложение автоматически его считает.\n\n Перед оплатой проверьте, что все поля заполнены правильно.\n\n Чтобы оплатить квитанцию, сохраненнуюв телефоне, откройте ее с помощью кнопки \"Из файла\", и отсканируйте QR-код."))) )
                    
                case _ as QRViewModelAction.Flashlight:
                    print("QrViewModelAction.Flashlight")
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                    
                case let payload as ModelAction.Media.GalleryPermission.Response:
                    
                    withAnimation {
                        
                        self.bottomSheet = nil
                    }
                    
                    if payload.result {
                        
                        self.link = .imagePicker(.init(closeAction: { [weak self] image in
                            
                            guard let image = image else { return }
                            guard let qr = self?.string(from: image) else { return }
                            
                            let result = Self.resolve(data: qr)
                            
                            self?.action.send(QRViewModelAction.Result(result: result))
                            
                        }))
                        
                    } else {
                        
                        self.alert = .init(title: "Ошибка", message: "Нет доступа к галереи", primary: .init(type: .default, title: "Ok", action: { [weak self] in self?.alert = nil}))
                    }
                    
                case _ as ModelAction.Media.DocumentPermission.Response:
                    
                    withAnimation {
                        
                        self.bottomSheet = nil
                    }
                    
                        
                    self.link = .documentPicker(.init(closeAction: { [weak self] url in
                        
                        guard let url = url,
                              let image = self?.qrFromPDF(url: url),
                              let qr = self?.string(from: image)else {
                            return
                        }
      
                        let result = Self.resolve(data: qr)
                        
                        self?.action.send(QRViewModelAction.Result(result: result))
                        
                    }))
                    
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
            
            case imageCapture(ImageCaptureViewModel)
            case info(QRInfoViewComponent)
            case choiseDocument(QRButtonsView.ViewModel)
        }
    }
    
    enum Link {
        
        case imagePicker(ImagePickerViewModel)
        case documentPicker(DocumentPickerViewModel)
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
    
    func qrFromPDF(url: URL) -> UIImage? {
        
        guard let document = CGPDFDocument(url as CFURL) else { return nil }
        
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
    
    private func createButtons() -> [ButtonIconTextView.ViewModel] {
        
        return [
            ButtonIconTextView.ViewModel(icon: .init(image: .ic24Image, background: .circle), title: .init(text: "Из файла"), orientation: .vertical, action: { [weak self] in
                self?.action.send(QRViewModelAction.OpenDocument())
            }),
            ButtonIconTextView.ViewModel(icon: .init(image: .ic24ZapOff, background: .circle), title: .init(text: "Фонарик"), orientation: .vertical, action: { [weak self] in
                self?.action.send(QRViewModelAction.Flashlight())
            }),
            ButtonIconTextView.ViewModel(icon: .init(image: .ic24AlertCircle, background: .circle), title: .init(text: "Инфо"), orientation: .vertical, action: { [weak self] in
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
    
    private func flashlight() throws {
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
    struct Flashlight: Action {}
    struct Result: Action {
        
        let result: QRViewModel.Result
    }
}
