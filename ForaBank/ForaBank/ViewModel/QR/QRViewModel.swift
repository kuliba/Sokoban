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
    let scanner = QRScannerView(viewModel: .init())
    let title: String
    let subTitle: String
    
    @Published var buttons: [ButtonIconTextView.ViewModel]
    @Published var clouseButton: ButtonSimpleView.ViewModel
    
    @Published var link: Link? { didSet { isLinkActive = link != nil } }
    @Published var isLinkActive: Bool = false
    @Published var bottomSheet: BottomSheet?
    @Published var alert: Alert.ViewModel?
    
    private let model = Model.shared
    private var bindings = Set<AnyCancellable>()
    
    
    init(title: String, subTitle: String, buttons: [ButtonIconTextView.ViewModel], clouseButton: ButtonSimpleView.ViewModel) {
        self.title = title
        self.subTitle = subTitle
        self.buttons = buttons
        self.clouseButton = clouseButton
    }
    
    convenience init(closeAction: @escaping () -> Void) {
        let clouseButton = ButtonSimpleView.ViewModel(title: "Отмена", style: .gray, action: closeAction)
        self.init(title: "Наведите камеру", subTitle: "на QR-код", buttons: [], clouseButton: clouseButton)
        self.buttons = createButtons()
        bind()
    }

    static func resolve(data: String) -> Result {
        
        if let qrCode = QRCode(string: data) {
            
            if qrCode.original.contains("qr.nspk.ru") {
                
                guard let url = URL(string: data) else {return Result.unknown(qrCode.original)}
                return Result.c2bURL(url)
            } else {
                return Result.qrCode(qrCode)
            }
        } else if data.contains("https://") {
            
            guard let url = URL(string: data) else {return Result.unknown(data)}
            return Result.url(url)
        } else {
            
            return Result.unknown(data)
        }
    }
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
                            print("Document")
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
                            // Получаем фото
                        }))
                        
                    } else {
                        
                        self.alert = .init(title: "Ошибка", message: "Нет доступа к галереи", primary: .init(type: .default, title: "Ok", action: { [weak self] in self?.alert = nil}))
                    }
                    
                default:
                    break
                    
                }
                
            }.store(in: &bindings)
        
        scanner.viewModel.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                    
                case let payload as QRScannerView.Response:
                    
                    switch payload {
                    case .success(let qr):
                        
                        let result = Self.resolve(data: qr)
                        
                        switch result {
                        case .qrCode(let qr):
                            self.alert = .init(title: "QR", message: qr.original, primary: .init(type: .default, title: "Ok", action: { [weak self] in self?.alert = nil}))
                            
                        case .c2bURL(let qr):
                            self.alert = .init(title: "C2b", message: qr.absoluteString, primary: .init(type: .default, title: "Ok", action: { [weak self] in self?.alert = nil}))
                            
                        case .url(let qr):
                            self.alert = .init(title: "Url", message: qr.absoluteString, primary: .init(type: .default, title: "Ok", action: { [weak self] in self?.alert = nil}))
                            
                        case .unknown(let qr):
                            self.alert = .init(title: "Unknown", message: qr, primary: .init(type: .default, title: "Ok", action: { [weak self] in self?.alert = nil}))
                        }
                        
                    case .failure:
                        self.alert = .init(title: "QR", message: "Не распознан", primary: .init(type: .default, title: "Ok", action: { [weak self] in self?.alert = nil}))
                    }
                default:
                    break
                }
            }.store(in: &bindings)
    }
    
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
    
    enum Result {

       case qrCode(QRCode)
       case c2bURL(URL)
       case url(URL)
       case unknown(String)
    }
}

enum QRViewModelAction {
    
    struct OpenDocument: Action {}
    struct Info: Action {}
    struct Flashlight: Action {}
}
