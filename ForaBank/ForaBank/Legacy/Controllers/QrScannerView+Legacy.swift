//
//  QrView+Legacy.swift
//  ForaBank
//
//  Created by Дмитрий on 01.07.2022.
//

import Foundation
import SwiftUI
import Combine

struct QrScannerView: UIViewControllerRepresentable {
    
    let viewModel: QrViewModel
    
    func makeUIViewController(context: Context) -> UIViewController {
        guard let controller = QRViewController.storyboardInstance() else {
            return UIViewController()
        }
        
        controller.viewModel = viewModel
        controller.modalPresentationStyle = .fullScreen
                
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

}

class QrViewModel: ObservableObject {
    
    let model = Model.shared
    let action: PassthroughSubject<Action, Never> = .init()
    let title: String
    @Published var link: Link? { didSet { isLinkActive = link != nil } }
    @Published var isLinkActive: Bool = false
    @Published var buttons: [QROptionButtonView.ViewModel]
    @Published var clouseButton: ButtonSimpleView.ViewModel
    @Published var bottomSheet: BottomSheet?
    @Published var alert: Alert.ViewModel?
    private var bindings = Set<AnyCancellable>()
    
    init(title: String, buttons: [QROptionButtonView.ViewModel], clouseButton: ButtonSimpleView.ViewModel) {
        self.title = title
        self.buttons = buttons
        self.clouseButton = clouseButton
    }
    
    convenience init(closeAction: @escaping () -> Void) {
        let clouseButton = ButtonSimpleView.ViewModel(title: "Отмена", style: .gray, action: closeAction)
        self.init(title: "Наведите камеру\nна QR-код", buttons: [], clouseButton: clouseButton)
        self.buttons = createItems()
        bind()
    }
    
    private func createItems() -> [QROptionButtonView.ViewModel] {
        
        let buttons = [
            QROptionButtonView.ViewModel(id: UUID(), icon: .ic24Image, title: "Из файла", action: {
                self.action.send(QrViewModelAction.OpenDocument())
            }),
            QROptionButtonView.ViewModel(id: UUID(), icon: .ic24ZapOff ,title: "Фонарик", action: {
                self.action.send(QrViewModelAction.Flashlight())
            }),
            QROptionButtonView.ViewModel(id: UUID(), icon: .ic24AlertCircle,title: "Инфо", action: {
                self.action.send(QrViewModelAction.Info())
            })]
        
        return buttons
    }
    
    func bind() {
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                switch action {
                    
                case _ as QrViewModelAction.OpenDocument:
                    self.bottomSheet = .init(sheetType: .choiseDocument(.init(buttons: [
                        .init(icon: .init(image: .ic12Clock, background: .circle), title: .init(text: "Из фото"), orientation: .horizontal, action: {
                            self.bottomSheet = nil
                            self.model.action.send(ModelAction.Media.GalleryPermission.Request())
                        }),
                        .init(icon: .init(image: .ic12Clock, background: .circle), title: .init(text: "Из Документов"), orientation: .horizontal, action: {
                            print("Document")
                        })
                    ])))
                    
                case _ as QrViewModelAction.Info:
                    self.bottomSheet = .init(sheetType: .info(.init(viewModel: .init(icon: .ic24AlertCircle,
                                                                                     title: "Сканировать QR-код",
                                                                                     content: "Наведите камеру телефона на QR-код, и приложение автоматически его считает.\n\n Перед оплатой проверьте, что все поля заполнены правильно.\n\n Чтобы оплатить квитанцию, сохраненнуюв телефоне, откройте ее с помощью кнопки \"Из файла\", и отсканируйте QR-код."))) )
                    
                case _ as QrViewModelAction.Flashlight:
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
    }
    
    struct BottomSheet: Identifiable {
        
        let id = UUID()
        let sheetType: SheetType
        
        enum SheetType {
            
            case imageCapture(ImageCaptureViewModel)
            case info(QRInfoView)
            case choiseDocument(QRButtonsView.ViewModel)
        }
    }
    
    enum Link {
        
        case imagePicker(ImagePickerViewModel)
    }
}

enum QrViewModelAction {
    
    struct OpenDocument: Action {}
    struct Info: Action {}
    struct Flashlight: Action {}
}
