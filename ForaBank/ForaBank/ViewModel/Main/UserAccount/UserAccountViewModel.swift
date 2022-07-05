//
//  UserAccountViewModel.swift
//  ForaBank
//
//  Created by Mikhail on 18.04.2022.
//

import Foundation
import SwiftUI
import Combine

class UserAccountViewModel: ObservableObject {
    
    let action: PassthroughSubject<Action, Never> = .init()
    
    let navigationBar: NavigationBarView.ViewModel
    
    @Published var avatar: AvatarViewModel?
    @Published var sections: [AccountSectionViewModel]
    @Published var exitButton: AccountCellFullButtonView.ViewModel? = nil
    @Published var link: Link? { didSet { isLinkActive = link != nil } }
    @Published var isLinkActive: Bool = false
    @Published var bottomSheet: BottomSheet?
    @Published var sheet: Sheet?
    @Published var sheetFullscreen: SheetFullscreen?
    @Published var isShowExitAlert: AlertViewModel?
    @Published var alert: Alert.ViewModel?
    
    private let model: Model
    private var bindings = Set<AnyCancellable>()
    
    init(navigationBar: NavigationBarView.ViewModel, avatar: AvatarViewModel, sections: [AccountSectionViewModel], exitButton: AccountCellFullButtonView.ViewModel, model: Model = .emptyMock) {
        
        self.model = model
        self.navigationBar = navigationBar
        self.avatar = avatar
        self.sections = sections
        self.exitButton = exitButton
        
    }
    
    init(model: Model, clientInfo: ClientInfoData, dismissAction: @escaping () -> Void) {
        
        self.model = model
        sections = []
        navigationBar = .init(title: "Профиль", leftButtons: [
            NavigationBarView.ViewModel.BackButtonViewModel(icon: .ic24ChevronLeft, action: dismissAction)
        ])
                
        exitButton = .init(
            icon: .ic24LogOut, content: "Выход из приложения", action: { [weak self] in
                self?.action.send(UserAccountViewModelAction.ExitAction())
            })
                
        bind()
    }
        
    func bind() {
        
        model.clientInfo
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] clientInfo in
                
                guard let clientInfo = clientInfo else { return }
                sections = createSections(userData: clientInfo)
                bind(sections)
                
            }.store(in: &bindings)
        
        model.clientPhoto
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] photo in
                
                avatar = .init(
                    image: photo?.image, action: { [weak self] in
                        self?.action.send(UserAccountViewModelAction.AvatarAction())
                    })
                
            }.store(in: &bindings)
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                    
                case let payload as ModelAction.Media.CameraPermission.Response:
                    
                    bottomSheet = nil
                    
                    if payload.result {
                        
                        self.sheetFullscreen = .init(type: .imageCapture(.init(closeAction: { [weak self] image in
                            
                            self?.action.send(UserAccountViewModelAction.SaveAvatarImage(image: image))
                        })))
                        
                    } else {
                        
                        alert = .init(title: "Ошибка", message: "Нет доступа к камере", primary: .init(type: .default, title: "Ok", action: { [weak self] in self?.alert = nil}))
                        
                    }
                    
                case let payload as ModelAction.Media.GalleryPermission.Response:
                    
                    bottomSheet = nil
                    
                    if payload.result {
                        
                        self.sheetFullscreen = .init(type: .imagePicker(.init(closeAction: { [weak self] image in
                            
                            self?.action.send(UserAccountViewModelAction.SaveAvatarImage(image: image))
                        })))
                        
                    } else {
                        
                        alert = .init(title: "Ошибка", message: "Нет доступа к галереи", primary: .init(type: .default, title: "Ok", action: { [weak self] in self?.alert = nil}))
                    }
                    
                default:
                    break
                    
                }
                
            }.store(in: &bindings)
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {

                case _ as UserAccountViewModelAction.AvatarAction:
                    var actions: [UserAccountPhotoSourceView.ViewModel.ButtonViewModel] = []
                    
                    if model.cameraIsAvailable {
                        actions.append(.init(icon: .ic24Camera, content: "Сделать фото") { [weak self] in
                            
                            self?.model.action.send(ModelAction.Media.CameraPermission.Request())
                            
                        })
                    }
                    
                    if model.galleryIsAvailable {
                        
                        actions.append(.init(icon: .ic24Image, content: "Выбрать из галереи") { [weak self] in
                            
                            self?.model.action.send(ModelAction.Media.GalleryPermission.Request())
                            
                        })
                    }
                    
                    if actions.count > 0 {
                        
                        bottomSheet = .init(sheetType: .camera(UserAccountPhotoSourceView.ViewModel(items: actions)))
                    }
                    
                case let payload as UserAccountViewModelAction.SaveAvatarImage:
                    
                    guard let image = payload.image?.resizeImageTo(size: .init(width: 100, height: 100)) else { return }
                    guard let photoData = ClientPhotoData(with: image) else { return }

                    model.action.send(ModelAction.ClientPhoto.Save(image: photoData))
                    
                case _ as UserAccountViewModelAction.ExitAction:
                    isShowExitAlert = AlertViewModel(title: "Выход", message: "Вы действительно хотите выйти из учетной записи?\nДля повторного входа Вам необходимо будет пройти повторную регистрацию", primaryButton: .destructive(Text("Выход"), action: {
                        self.model.action.send(ModelAction.Auth.Logout())
                    }), secondaryButton: .cancel(Text("Отмена")))
                    
                default:
                    break
                    
                }
                
            }.store(in: &bindings)
    }
    
    private func bind(_ sections: [AccountSectionViewModel]) {
        
        for section in sections {
            
            section.action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {

                    case _ as UserAccountViewModelAction.ChangeUserName:
                        print("Open Изменить Имя")
                        
                    case _ as UserAccountViewModelAction.OpenFastPayment:
                        let viewModel = MeToMeSettingView.ViewModel
                            .init(model: model.fastPaymentContractFullInfo.value
                                .map { $0.getFastPaymentContractFindListDatum() },
                                  newModel: model,
                                  closeAction: {[weak self] in self?.action.send(UserAccountViewModelAction.CloseLink())})
                        link = .fastPaymentSettings(viewModel)
                        
                    case let payload as UserAccountViewModelAction.Switch:
                        switch payload.type {
                            
                        case .faceId:
                            print("Open FaceIdSwitch", payload.value)
                            
                        case .notification:
                            print("Open NotificationSwitch", payload.value)
                        }
                        
                    case let payload as UserAccountViewModelAction.OpenDocument:
                        guard let clientInfo = model.clientInfo.value else { return }
                        switch payload.type {
                            
                        case .passport:
                            self.link = .userDocument(.init(clientInfo: clientInfo, itemType: .passport, dismissAction: {[weak self] in self?.action.send(UserAccountViewModelAction.CloseLink())}))
                            
                        case .inn:
                            guard let inn = clientInfo.INN else { return }
                            self.bottomSheet = .init(sheetType: .inn(.init(itemType: payload.type, content: inn)))
                            
                        case .adressPass:
                            self.bottomSheet = .init(sheetType: .inn(.init(itemType: payload.type, content: clientInfo.address)))
                            
                        case .adress:
                            guard let addressResidential = clientInfo.addressResidential else { return }
                            self.bottomSheet = .init(sheetType: .inn(.init(itemType: payload.type, content: addressResidential)))
                        }
                        
                    case _ as UserAccountViewModelAction.CloseLink:
                        link = nil
                        
                    default:
                        break
                        
                    }
                    
                }.store(in: &bindings)
        }
    }
    
    func createSections(userData: ClientInfoData) -> [AccountSectionViewModel] {
        [
            UserAccountContactsView.ViewModel(userData: userData, isCollapsed: false),
            UserAccountDocumentsView.ViewModel(userData: userData, isCollapsed: false),
            UserAccountPaymentsView.ViewModel(isCollapsed: false),
            UserAccountSecurityView.ViewModel(isActiveFaceId: false, isActivePush: true, isCollapsed: false)
        ]
    }
}

extension UserAccountViewModel {
    
    struct AlertViewModel: Identifiable {
        
        let id = UUID()
        let title: String
        let message: String
        let primaryButton: Alert.Button
        let secondaryButton: Alert.Button
        
        internal init(title: String, message: String, primaryButton: Alert.Button, secondaryButton: Alert.Button) {
            self.title = title
            self.message = message
            self.primaryButton = primaryButton
            self.secondaryButton = secondaryButton
        }
    }
}

extension UserAccountViewModel {
    
    class AvatarViewModel: ObservableObject {
        
        @Published var image: Image?
        let action: () -> Void
        
        internal init(image: Image?, action: @escaping () -> Void) {
            self.image = image
            self.action = action
        }
    }
    
    class AccountSectionViewModel: ObservableObject, Identifiable {
        
        let action: PassthroughSubject<Action, Never> = .init()
        
        var id: String { type.rawValue }
        var type: AccountSectionType { fatalError("Implement in subclass")}
    }

    class AccountSectionCollapsableViewModel: AccountSectionViewModel {
        
        var title: String { type.name }
        @Published var isCollapsed: Bool
        
        init(isCollapsed: Bool) {
            
            self.isCollapsed = isCollapsed
            super.init()
        }
    }

    enum AccountSectionType: String, CaseIterable, Codable {
        
        case contacts
        case documents
        case payments
        case security
        
        var name: String {
            
            switch self {
            case .contacts: return "Контакты"
            case .documents: return "Документы"
            case .payments: return "Платежи и переводы"
            case .security: return "Безопасность"
            }
        }
    }
    
    enum Link {
        
        case userDocument(UserDocumentViewModel)
        case fastPaymentSettings(MeToMeSettingView.ViewModel)
    }
    

    struct Sheet: Identifiable {
        
        let id = UUID()
        let sheetType: SheetType
        
        enum SheetType {
            case userDocument(UserDocumentViewModel)
        }
    }
    
    struct SheetFullscreen: Identifiable, Equatable {
        
        static func == (lhs: UserAccountViewModel.SheetFullscreen, rhs: UserAccountViewModel.SheetFullscreen) -> Bool {
            lhs.id == rhs.id
        }
        
        let id = UUID()
        let type: Kind
        
        enum Kind {
            
            case imageCapture(ImageCaptureViewModel)
            case imagePicker(ImagePickerViewModel)
        }
    }
    
    struct BottomSheet: Identifiable {
        
        let id = UUID()
        let sheetType: SheetType
        
        enum SheetType {
            case inn(UserAccountDocumentInfoView.ViewModel)
            case camera(UserAccountPhotoSourceView.ViewModel)
        }
    }
    
}

enum UserAccountViewModelAction {

    struct PullToRefresh: Action {}
    
    struct CloseLink: Action {}
    
    struct ChangeUserName: Action {}
    
    struct AvatarAction: Action {}
    
//    struct SettingsAction: Action {}
    
    struct ExitAction: Action {}
    
    struct OpenDocument: Action {
        let type: DocumentCellType
    }
    
    struct SaveAvatarImage: Action {
        let image: UIImage?
    }
    
    struct OpenFastPayment: Action {}
    
    struct Switch: Action {
        
        let type: AccountCellSwitchView.ViewModel.Kind
        let value: Bool
    }
}
