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
    @Published var deleteAccountButton: AccountCellFullButtonWithInfoView.ViewModel? = nil
    @Published var link: Link? { didSet { isLinkActive = link != nil } }
    @Published var isLinkActive: Bool = false
    @Published var bottomSheet: BottomSheet?
    @Published var camSheet: CamSheet?
    @Published var sheet: Sheet?
    @Published var sheetFullscreen: SheetFullscreen?
    @Published var alert: Alert.ViewModel?
    
    @Published var textFieldAlert: AlertTextFieldView.ViewModel?
    
    private let model: Model
    private var bindings = Set<AnyCancellable>()
    
    init(navigationBar: NavigationBarView.ViewModel, avatar: AvatarViewModel, sections: [AccountSectionViewModel], exitButton: AccountCellFullButtonView.ViewModel, deleteAccountButton: AccountCellFullButtonWithInfoView.ViewModel, model: Model = .emptyMock) {
        
        self.model = model
        self.navigationBar = navigationBar
        self.avatar = avatar
        self.sections = sections
        self.exitButton = exitButton
        self.deleteAccountButton = deleteAccountButton
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
                
        deleteAccountButton = .init(
            icon: .ic24UserX, content: "Удалить учетную запись",
            infoButton: .init(icon: .ic24Info, action: { [weak self] in
                self?.action.send(UserAccountViewModelAction.DeleteInfoAction())
            }),
            action: { [weak self] in
                self?.action.send(UserAccountViewModelAction.DeleteAction())
            })
        bind()
    }
        
    func bind() {
        
        model.clientInfo
            .combineLatest(model.clientName)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] info in
                
                guard let clientInfo = info.0 else { return }
                sections = createSections(userData: clientInfo, customName: info.1)
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
                    
                    if payload.result {
                        
                        self.sheetFullscreen = .init(type: .imageCapture(.init(closeAction: { [weak self] image in
                            
                            self?.action.send(UserAccountViewModelAction.SaveAvatarImage(image: image))
                        })))
                        
                    } else {
                        
                        self.alert = .init(title: "Ошибка", message: "Нет доступа к камере", primary: .init(type: .default, title: "Ok", action: { [weak self] in self?.alert = nil}))
                        
                    }
                    
                case let payload as ModelAction.Media.GalleryPermission.Response:
                    
                    if payload.result {
                        
                        self.sheetFullscreen = .init(type: .imagePicker(.init(closeAction: { [weak self] image in
                            
                            self?.action.send(UserAccountViewModelAction.SaveAvatarImage(image: image))
                        })))
                        
                    } else {
                        
                        self.alert = .init(title: "Ошибка", message: "Нет доступа к галереи", primary: .init(type: .default, title: "Ok", action: { [weak self] in self?.alert = nil}))
                    }
                    
                default:
                    break
                    
                }
                
            }.store(in: &bindings)
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {

                case _ as UserAccountViewModelAction.CloseLink:
                    link = nil
                    
                case _ as UserAccountViewModelAction.CloseFieldAlert:
                    textFieldAlert = nil
                    
                case _ as UserAccountViewModelAction.AvatarAction:
                    var buttons: [Alert.Button] = []
                    
                    if model.cameraIsAvailable {
                        buttons.append(Alert.Button.default(Text("Сделать фото")) {
                            self.model.action.send(ModelAction.Media.CameraPermission.Request())
                        })
                    }
                    
                    if model.galleryIsAvailable {
                        buttons.append(Alert.Button.default(Text("Выбрать из галереи")) {
                            self.model.action.send(ModelAction.Media.GalleryPermission.Request())
                        })
                    }
                    
                    if model.clientPhoto.value != nil {
                        buttons.append(Alert.Button.default(Text("Удалить")) {
                            self.model.action.send(ModelAction.ClientPhoto.Delete())
                        })
                    }
                    
                    buttons.append(Alert.Button.cancel(Text("Отмена")))
                    if buttons.count > 1 {
                        camSheet = .init(buttons: buttons)
                    }
                    
                case let payload as UserAccountViewModelAction.SaveAvatarImage:
                    
                    guard let image = payload.image?.resizeImageTo(size: .init(width: 100, height: 100)) else { return }
                    guard let photoData = ClientPhotoData(with: image) else { return }

                    model.action.send(ModelAction.ClientPhoto.Save(image: photoData))
                    
                case _ as UserAccountViewModelAction.ExitAction:
                    alert = .init(
                        title: "Выход", message: "Вы действительно хотите выйти из учетной записи?\nДля повторного входа Вам необходимо будет пройти повторную регистрацию",
                        primary: .init(type: .distructive, title: "Выход", action: { self.model.action.send(ModelAction.Auth.Logout())
                        }),
                        secondary: .init(type: .cancel, title: "Отмена", action: { }))
                    
                case _ as UserAccountViewModelAction.DeleteAction:
                    
                    alert = .init(
                        title: "Удалить учетную запись?", message: "Вы действительно хотите удалить свои данные из Фора-Онлайн?\n\nДля входа в приложение потребуется новая регистрация данных",
                        primary: .init(type: .distructive, title: "Ок", action: {
                            self.model.action.send(ModelAction.Auth.Logout())
                        }),
                        secondary: .init(type: .cancel, title: "Отмена", action: { }))
                    
                case _ as UserAccountViewModelAction.DeleteInfoAction:
                    
                    bottomSheet = .init(sheetType: .deleteInfo(.exitInfoViewModel))
                    
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
                        
                        textFieldAlert = .init(
                            title: "Имя", message: "Как к вам обращаться?\n* Имя не должно превышать 15 символов",
                            primary: .init(type: .default, title: "ОК", action: { [weak self] text in
                                
                                self?.action.send(UserAccountViewModelAction.CloseFieldAlert())
                                self?.model.action.send(ModelAction.ClientName.Save(name: text))
                                
                            }),
                            secondary: .init(type: .cancel, title: "Отмена", action: { [weak self] _ in
                                self?.action.send(UserAccountViewModelAction.CloseFieldAlert())
                            }))
                                                
                    case _ as UserAccountViewModelAction.OpenFastPayment:
                        
                        link = .fastPaymentSettings(MeToMeSettingView.ViewModel(
                            model: model.fastPaymentContractFullInfo.value
                                .map { $0.getFastPaymentContractFindListDatum() },
                            newModel: model,
                            closeAction: { [weak self] in
                                
                                self?.action.send(UserAccountViewModelAction.CloseLink())
                            }))
                        
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
                    
                    default:
                        break
                        
                    }
                    
                }.store(in: &bindings)
        }
    }
    
    func createSections(userData: ClientInfoData, customName: String?) -> [AccountSectionViewModel] {
        [
            UserAccountContactsView.ViewModel(userData: userData, customName: customName, isCollapsed: false),
            UserAccountDocumentsView.ViewModel(userData: userData, isCollapsed: false),
            UserAccountPaymentsView.ViewModel(isCollapsed: false),
            UserAccountSecurityView.ViewModel(isActiveFaceId: false, isActivePush: true, isCollapsed: false)
        ]
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
    
    struct CamSheet: Identifiable {
        
        let id = UUID()
        let buttons: [Alert.Button]
    }
    
    struct SheetFullscreen: Identifiable {
        
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
            case deleteInfo(UserAccountExitInfoView.ViewModel)
            case inn(UserAccountDocumentInfoView.ViewModel)
            case camera(UserAccountPhotoSourceView.ViewModel)
        }
    }
    
}

enum UserAccountViewModelAction {

    struct PullToRefresh: Action {}
    
    struct CloseLink: Action {}
    
    struct CloseFieldAlert: Action {}
    
    struct ChangeUserName: Action {}
    
    struct AvatarAction: Action {}
    
    struct ExitAction: Action {}
    
    struct DeleteAction: Action {}
    
    struct DeleteInfoAction: Action {}
    
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
