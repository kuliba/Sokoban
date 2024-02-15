//
//  UserAccountViewModel.swift
//  ForaBank
//
//  Created by Mikhail on 18.04.2022.
//

import Combine
import FastPaymentsSettings
import Foundation
import ManageSubscriptionsUI
import TextFieldModel
import SwiftUI
import UIPrimitives

class UserAccountViewModel: ObservableObject {
    
    let action: PassthroughSubject<Action, Never> = .init()
    
    let navigationBar: NavigationBarView.ViewModel
    
    @Published var avatar: AvatarViewModel?
    @Published var sections: [AccountSectionViewModel]
    @Published var exitButton: AccountCellFullButtonView.ViewModel? = nil
    @Published var deleteAccountButton: AccountCellFullButtonWithInfoView.ViewModel? = nil
    @Published private(set) var route: UserAccountRoute
    
    private let routeSubject = PassthroughSubject<UserAccountRoute, Never>()
    
    var appVersionFull: String? {
        
        model.authAppVersion.map { "Версия \($0)" }
    }
    
    private let model: Model
    private let navigationStateManager: UserAccountNavigationStateManager
    
    private let scheduler: AnySchedulerOfDispatchQueue
    private var bindings = Set<AnyCancellable>()
    
    private init(
        route: UserAccountRoute = .init(),
        navigationStateManager: UserAccountNavigationStateManager,
        navigationBar: NavigationBarView.ViewModel,
        avatar: AvatarViewModel,
        sections: [AccountSectionViewModel],
        exitButton: AccountCellFullButtonView.ViewModel,
        deleteAccountButton: AccountCellFullButtonWithInfoView.ViewModel,
        model: Model = .emptyMock,
        scheduler: AnySchedulerOfDispatchQueue = .main
    ) {
        self.route = route
        self.navigationStateManager = navigationStateManager
        self.model = model
        self.navigationBar = navigationBar
        self.avatar = avatar
        self.sections = sections
        self.exitButton = exitButton
        self.deleteAccountButton = deleteAccountButton
        self.scheduler = scheduler
    }
    
    init(
        route: UserAccountRoute = .init(),
        navigationStateManager: UserAccountNavigationStateManager,
        model: Model,
        clientInfo: ClientInfoData,
        dismissAction: @escaping () -> Void,
        action: Action? = nil,
        scheduler: AnySchedulerOfDispatchQueue = .main
    ) {
        self.route = route
        self.navigationStateManager = navigationStateManager
        self.model = model
        self.sections = []
        self.navigationBar = .init(title: "Профиль", leftItems: [
            NavigationBarView.ViewModel.BackButtonItemViewModel(icon: .ic24ChevronLeft, action: dismissAction)
        ])
        self.scheduler = scheduler
        self.exitButton = .init(
            icon: .ic24LogOut, content: "Выход из приложения", action: { [weak self] in
                self?.action.send(UserAccountViewModelAction.ExitAction())
            })
        
        self.deleteAccountButton = .init(
            icon: .ic24UserX, content: "Удалить учетную запись",
            infoButton: .init(icon: .ic24Info, action: { [weak self] in
                self?.action.send(UserAccountViewModelAction.DeleteInfoAction())
            }),
            action: { [weak self] in
                self?.action.send(UserAccountViewModelAction.DeleteAction())
            })
        
        routeSubject
            .receive(on: scheduler)
            .assign(to: &$route)
        
        bind()
        
        if let action {
            
            self.action.send(action)
        }
    }
}

extension UserAccountViewModel {
    
    func event(_ event: UserAccountEvent) {

        let (route, effect) = navigationStateManager.reduce(route, event)
        routeSubject.send(route)
        
        if let effect {
            
            navigationStateManager.handleEffect(effect) { [weak self] in self?.event($0) }
        }
    }
}

// MARK: - Bindings

private extension UserAccountViewModel {
    
    func bind(documentInfoViewModel: UserAccountDocumentInfoView.ViewModel) {
        
        documentInfoViewModel.action
            .receive(on: scheduler)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as UserAccountDocumentInfoViewAction.CopyDocument:
                    let clientInfo = self.model.clientInfo.value
                    
                    switch payload.type {
                    case .inn:
                        guard let inn = clientInfo?.inn else {
                            return
                        }
                        UIPasteboard.general.string = "ИНН: \(inn)"
                        
                    case .adressPass:
                        guard let address = clientInfo?.address else {
                            return
                        }
                        
                        UIPasteboard.general.string = "Адрес: \(address)"
                        
                    case .adress:
                        guard let addressResidential = clientInfo?.addressResidential else {
                            return
                        }
                        
                        UIPasteboard.general.string = "Адрес проживания: \(addressResidential)"
                        
                    default:
                        break
                    }
                    
                default:
                    break
                }
            }
            .store(in: &bindings)
    }
    
    func bind() {
        
        model.clientInfo
            .combineLatest(model.clientName)
            .receive(on: scheduler)
            .sink { [unowned self] info in
                
                guard let clientInfo = info.0 else { return }
                
                let clientNameData = info.1
                sections = createSections(userData: clientInfo, customName: clientNameData?.name)
                bind(sections)
            }
            .store(in: &bindings)
        
        model.clientPhoto
            .receive(on: scheduler)
            .sink { [unowned self] clientPhotoData in
                
                avatar = .init(
                    image: clientPhotoData?.photo.image, action: { [weak self] in
                        self?.action.send(UserAccountViewModelAction.AvatarAction())
                    })
            }
            .store(in: &bindings)
        
        model.action
            .receive(on: scheduler)
            .sink { [weak self] in self?.handleModelAction($0) }
            .store(in: &bindings)
        
        action
            .receive(on: scheduler)
            .sink { [weak self] in self?.handleAction($0) }
            .store(in: &bindings)
    }
    
    func bind(_ sections: [AccountSectionViewModel]) {
        
        for section in sections {
            
            section.action
                .receive(on: scheduler)
                .sink { [weak self] in self?.handleSectionAction($0) }
                .store(in: &bindings)
        }
    }
    
    func createSections(userData: ClientInfoData, customName: String?) -> [AccountSectionViewModel] {
        
        var sections: [AccountSectionViewModel] = [
            UserAccountContactsView.ViewModel(userData: userData, customName: customName, isCollapsed: false),
            UserAccountDocumentsView.ViewModel(userData: userData, isCollapsed: false),
            UserAccountPaymentsView.ViewModel(isCollapsed: false)]
        
        if let pushSetting: UserSettingPush = self.model.userSetting(for: .disablePush) {
            
            sections.append(UserAccountSecurityView.ViewModel(isActiveFaceId: false, isActivePush: pushSetting.value, isCollapsed: false))
            
        } else {
            
            sections.append(UserAccountSecurityView.ViewModel(isActiveFaceId: false, isActivePush: true, isCollapsed: false))
        }
        
        return sections
    }
}

private extension UserAccountViewModel {
    
    func handleModelAction(
        _ action: Action
    ) {
        switch action {
        case let payload as ModelAction.C2B.CancelC2BSub.Response:
            let paymentSuccessViewModel = PaymentsSuccessViewModel(paymentSuccess: .init(with: payload.data), model)
            
            event(.navigate(.link(
                .successView(paymentSuccessViewModel)
            )))
            
        case let payload as ModelAction.C2B.GetC2BDetail.Response:
            event(.navigate(.link(
                .successView(.init(
                    paymentSuccess: .init(
                        operation: nil,
                        parameters: payload.params),
                    model
                ))
            )))
            
        case let payload as ModelAction.Media.CameraPermission.Response:
            withAnimation {
                
                event(.dismiss(.bottomSheet))
            }
            
            if payload.result {
                event(.navigate(.bottomSheet(.init(
                    sheetType: .imageCapture(.init(
                        closeAction: { [weak self] image in
                            
                            self?.event(.dismiss(.bottomSheet))
                            self?.action.send(UserAccountViewModelAction.SaveAvatarImage(image: image))
                        }
                    ))
                ))))
                
            } else {
                
                event(.navigate(.alert(
                    .cameraPermissionError(event: .dismiss(.alert))
                )))
            }
            
        case let payload as ModelAction.Media.GalleryPermission.Response:
            withAnimation {
                
                    event(.dismiss(.bottomSheet))
            }
            
            if payload.result {
                
                event(.navigate(.link(
                    .imagePicker(.init(
                        closeAction: { [weak self] image in
                            
                            self?.action.send(UserAccountViewModelAction.SaveAvatarImage(image: image))
                        }
                    ))
                )))
                
            } else {
                
                event(.navigate(.alert(
                    .galleryPermissionError(event: .dismiss(.alert))
                )))
            }
            
        case _ as ModelAction.ClientInfo.Delete.Response:
            event(.navigate(.link(
                .deleteUserInfo(.init(model: self.model))
            )))
            
        default:
            break
        }
    }
    
    func handleAction(
        _ action: Action
    ) {
        switch action {
        case _ as PaymentsSuccessAction.Button.Close:
            self.action.send(PaymentsViewModelAction.Dismiss())
            
        case _ as UserAccountViewModelAction.CloseLink:
            event(.dismiss(.destination))
            
        case _ as UserAccountViewModelAction.CloseFieldAlert:
            event(.dismiss(.textFieldAlert))
            
        case _ as UserAccountViewModelAction.AvatarAction:
            var buttons: [ButtonIconTextView.ViewModel] = []
            
            if model.cameraIsAvailable {
                buttons.append(.init(icon: .init(image: .ic24Camera, style: .original, background: .circleSmall), title: .init(text: "Сделать фото", color: .textSecondary, style: .bold), orientation: .horizontal, action: { [weak self] in
                    self?.event(.dismiss(.bottomSheet))
                    self?.model.action.send(ModelAction.Media.CameraPermission.Request())
                }))
            }
            
            if model.galleryIsAvailable {
                buttons.append(.init(icon: .init(image: .ic24Image, style: .original, background: .circleSmall), title: .init(text: "Выбрать из галереи", color: .textSecondary, style: .bold), orientation: .horizontal, action: { [weak self] in
                    self?.event(.dismiss(.bottomSheet))
                    self?.model.action.send(ModelAction.Media.GalleryPermission.Request())
                }))
            }
            
            if model.clientPhoto.value != nil {
                buttons.append(.init(icon: .init(image: .ic24Trash2, style: .original, background: .circleSmall), title: .init(text: "Удалить", color: .textSecondary, style: .bold), orientation: .horizontal, action: { [weak self] in
                    self?.event(.dismiss(.bottomSheet))
                    self?.model.action.send(ModelAction.ClientPhoto.Delete())
                }))
            }
            
            event(.navigate(.bottomSheet(.init(
                sheetType: .avatarOptions(.init(buttons: buttons)))
            )))
            
        case let payload as UserAccountViewModelAction.SaveAvatarImage:
                                        event(.dismiss(.bottomSheet))
            
            guard let image = payload.image?.resizeImageTo(size: .init(width: 100, height: 100)),
                  let photoData = ImageData(with: image)
            else { return }
            
            model.action.send(ModelAction.ClientPhoto.Save(image: photoData))
            
        case _ as UserAccountViewModelAction.ExitAction:
            event(.navigate(.alert(.exit(event: .exit))))
            
        case _ as UserAccountViewModelAction.DeleteAction:
            event(.navigate(.alert(.delete(event: .deleteRequest))))
            
        case _ as UserAccountViewModelAction.DeleteInfoAction:
            event(.navigate(.bottomSheet(.init(
                sheetType: .deleteInfo(.exitInfoViewModel))
            )))
            
        case let payload as UserAccountViewModelAction.OpenSbpPay:
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) { [weak self] in
                
                withAnimation {
                    
                    self?.event(.navigate(.bottomSheet(.init(
                        sheetType: .sbpay(payload.sbpPay))
                    )))
                }
            }
            
        default:
            break
        }
    }
    
    func handleSectionAction(
        _ action: Action
    ) {
        switch action {
        case _ as UserAccountViewModelAction.ChangeUserName:
            event(.navigate(.textFieldAlert(.name(
                primaryAction: { [weak self] text in
                    
                    self?.action.send(UserAccountViewModelAction.CloseFieldAlert())
                    self?.model.action.send(ModelAction.ClientName.Save(name: text))
                },
                secondaryAction: { [weak self] _ in
                    
                    self?.action.send(UserAccountViewModelAction.CloseFieldAlert())
                }
            ))))
            
        case _ as UserAccountViewModelAction.OpenManagingSubscription:
            let viewModel = navigationStateManager.makeSubscriptionsViewModel(
                { [weak self] token, title in
                    
                    self?.event(.navigate(.alert(.cancelC2BSub(
                        title: title,
                        event: .cancelC2BSub(token)
                    ))))
                },
                { [weak self] token in
                    
                    self?.model.action.send(ModelAction.C2B.GetC2BDetail.Request(token: token))
                })
            
            self.event(.navigate(.link(.managingSubscription(viewModel))))
            
        case _ as UserAccountViewModelAction.OpenFastPayment:
            switch navigationStateManager.fastPaymentsFactory.fastPaymentsViewModel {
            case let .legacy(makeLegacy):
                let data = model.fastPaymentContractFullInfo.value
                    .map { $0.getFastPaymentContractFindListDatum() }
                
                self.event(.navigate(.link(
                    .fastPaymentSettings(.legacy(
                        makeLegacy(
                            data,
                            { [weak self] in self?.event(.dismiss(.destination)) }
                        )
                    ))
                )))
                
#warning("move to reducer with event?")
            case let .new(makeNew):
                let viewModel = makeNew(scheduler)
                let cancellable = viewModel.$state
                    .dropFirst()
                    .removeDuplicates()
                    .map(UserAccountEvent.FastPaymentsSettings.updated)
                    .receive(on: scheduler)
                    .sink { [weak self] in self?.event(.fps($0)) }
#warning("and change to effect (??) when moved to `reduce` (?)")
                viewModel.event(.appear)
                
                self.event(.navigate(.link(
                    .fastPaymentSettings(.new(
                        .init(viewModel, cancellable)
                    ))
                )))
            }
            
        case let payload as UserAccountViewModelAction.Switch:
            switch payload.type {
            case .faceId:
                //TODO: set action
                break
                
            case .notification:
                self.model.action.send(ModelAction.Settings.UpdateUserSettingPush(userSetting: .init(value: payload.value)))
            }
            
        case let payload as UserAccountViewModelAction.OpenDocument:
            guard let clientInfo = model.clientInfo.value
            else { return }
            
            switch payload.type {
                
            case .passport:
                self.event(.navigate(.link(
                    .userDocument(.init(
                        clientInfo: clientInfo,
                        itemType: .passport,
                        dismissAction: { [weak self] in
                            
                            self?.action.send(UserAccountViewModelAction.CloseLink())
                        }
                    ))
                )))
                
            case .inn:
                guard let inn = clientInfo.inn else { return }
                
                let documentInfoViewModel = UserAccountDocumentInfoView.ViewModel(itemType: payload.type, content: inn)
                self.event(.navigate(.bottomSheet(.init(
                    sheetType: .inn(documentInfoViewModel))
                )))
                self.bind(documentInfoViewModel: documentInfoViewModel)
                
            case .adressPass:
                let address = clientInfo.address
                let documentInfoViewModel = UserAccountDocumentInfoView.ViewModel(itemType: payload.type, content: address)
                self.event(.navigate(.bottomSheet(.init(
                    sheetType: .inn(documentInfoViewModel))
                )))
                self.bind(documentInfoViewModel: documentInfoViewModel)
                
            case .adress:
                guard let addressResidential = clientInfo.addressResidential
                else { return }
                
                let documentInfoViewModel = UserAccountDocumentInfoView.ViewModel(itemType: payload.type, content: addressResidential)
                self.event(.navigate(.bottomSheet(.init(
                    sheetType: .inn(documentInfoViewModel))
                )))
                self.bind(documentInfoViewModel: documentInfoViewModel)
            }
            
        default:
            break
        }
    }
}

// MARK: - Helpers

private extension AlertModelOf<UserAccountEvent> {
    
    static func cameraPermissionError(
        event: UserAccountEvent
    ) -> Self {
        
        .init(
            title: "Ошибка",
            message: "Нет доступа к камере",
            primaryButton: .init(
                type: .default,
                title: "Ok",
                event: event
            )
        )
    }
    
    static func cancelC2BSub(
        title: String,
        event: UserAccountEvent
    ) -> Self {
        
        .init(
            title: title,
            message: nil,
            primaryButton: .init(
                type: .cancel,
                title: "Отмена",
                event: .dismiss(.alert)
            ),
            secondaryButton: .init(
                type: .default,
                title: "Отключить",
                event: event
            )
        )
    }
    
    static func delete(
        event: UserAccountEvent
    ) -> Self {
        
        .init(
            title: "Удалить учетную запись?",
            message: "Вы действительно хотите удалить свои данные из Фора-Онлайн?\n\nДля входа в приложение потребуется новая регистрация данных",
            primaryButton: .init(
                type: .default,
                title: "ОК",
                event: event
            ),
            secondaryButton: .init(
                type: .cancel,
                title: "Отмена",
                event: .dismiss(.alert)
            )
        )
    }
    
    static func exit(
        event: UserAccountEvent
    ) -> Self {
        
        .init(
            title: "Выход",
            message: "Вы действительно хотите выйти из учетной записи?\nДля повторного входа Вам необходимо будет пройти повторную регистрацию",
            primaryButton: .init(
                type: .default,
                title: "Выход",
                event: event
            ),
            secondaryButton: .init(
                type: .cancel,
                title: "Отмена",
                event: .dismiss(.alert)
            )
        )
    }
    
    static func galleryPermissionError(
        event: UserAccountEvent
    ) -> Self {
        
        .init(
            title: "Ошибка",
            message: "Нет доступа к галереи",
            primaryButton: .init(
                type: .default,
                title: "Ok",
                event: event
            )
        )
    }
    
}

private extension AlertTextFieldView.ViewModel {
    
    static func name(
        primaryAction: @escaping (String?) -> Void,
        secondaryAction: @escaping (String?) -> Void
    ) -> AlertTextFieldView.ViewModel {
        
        .init(
            title: "Имя",
            message: "Как к вам обращаться?\n* Имя не должно превышать 15 символов",
            maxLength: 15,
            primary: .init(
                type: .default,
                title: "ОК",
                action: primaryAction
            ),
            secondary: .init(
                type: .cancel,
                title: "Отмена",
                action: secondaryAction
            )
        )
    }
}

// MARK: - Types

extension UserAccountViewModel {
    
    typealias Dispatch = (UserAccountEvent) -> Void
    
    typealias RouteDispatch = (UserAccountEvent.NavigateEvent) -> Void
    typealias Reduce = (UserAccountRoute, UserAccountEvent, @escaping RouteDispatch) -> (UserAccountRoute, UserAccountEffect?)
    
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
}

enum UserAccountViewModelAction {
    
    struct PullToRefresh: Action {}
    
    struct CloseLink: Action {}
    
    struct CloseFieldAlert: Action {}
    
    struct ChangeUserName: Action {}
    
    struct AvatarAction: Action {}
    
    struct OpenSbpPay: Action {
        
        let sbpPay: SbpPayViewModel
    }
    
    struct ExitAction: Action {}
    
    struct DeleteAction: Action {}
    
    struct DeleteInfoAction: Action {}
    
    struct OpenDocument: Action {
        
        let type: DocumentCellType
    }
    
    struct SaveAvatarImage: Action {
        
        let image: UIImage?
    }
    
    struct OpenManagingSubscription: Action {}
    
    struct OpenFastPayment: Action {}
    
    struct Switch: Action {
        
        let type: AccountCellSwitchView.ViewModel.Kind
        let value: Bool
    }
}

// MARK: - Preview Content

extension UserAccountViewModel {
    
    static let sample = UserAccountViewModel(
        navigationStateManager: .preview,
        navigationBar: .sample,
        avatar: .init(
            image: Image("imgMainBanner2"),
            //image: nil,
            action: {
                //TODO: set action
            }),
        sections:
            [UserAccountContactsView.ViewModel.contact,
             UserAccountDocumentsView.ViewModel.documents,
             UserAccountPaymentsView.ViewModel.payments,
             UserAccountSecurityView.ViewModel.security
            ],
        exitButton: .init(
            icon: .ic24LogOut,
            content: "Выход из приложения",
            action: {
                //TODO: set action
            }),
        deleteAccountButton: .init(
            icon: .ic24UserX, content: "Удалить учетную запись",
            infoButton: .init(icon: .ic24Info, action: { }),
            action: {}
        ),
        scheduler: .main
    )
}
