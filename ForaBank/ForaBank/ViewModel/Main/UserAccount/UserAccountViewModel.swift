//
//  UserAccountViewModel.swift
//  ForaBank
//
//  Created by Mikhail on 18.04.2022.
//

import Foundation
import SwiftUI
import Combine
import ManageSubscriptionsUI
import TextFieldModel

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
    @Published var sheet: Sheet?
    @Published var alert: Alert.ViewModel?
    @Published var textFieldAlert: AlertTextFieldView.ViewModel?
    
    var appVersionFull: String? {
        
        guard let version = model.authAppVersion else {
            return nil
        }
        
        return "Версия \(version)"
    }
    
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
    
    init(
        model: Model,
        clientInfo: ClientInfoData,
        dismissAction: @escaping () -> Void,
        action: Action? = nil
    ) {
        
        self.model = model
        sections = []
        navigationBar = .init(title: "Профиль", leftItems: [
            NavigationBarView.ViewModel.BackButtonItemViewModel(icon: .ic24ChevronLeft, action: dismissAction)
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
        
        if let action = action {
            
            self.action.send(action)
        }
    }
    
    func bind(documentInfoViewModel: UserAccountDocumentInfoView.ViewModel) {
        
        documentInfoViewModel.action
            .receive(on: DispatchQueue.main)
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
            }.store(in: &bindings)
    }
    
    func bind() {
        
        model.clientInfo
            .combineLatest(model.clientName)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] info in
                
                guard let clientInfo = info.0 else { return }
                let clientNameData = info.1
                sections = createSections(userData: clientInfo, customName: clientNameData?.name)
                bind(sections)
                
            }.store(in: &bindings)
        
        model.clientPhoto
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] clientPhotoData in
                
                avatar = .init(
                    image: clientPhotoData?.photo.image, action: { [weak self] in
                        self?.action.send(UserAccountViewModelAction.AvatarAction())
                    })
                
            }.store(in: &bindings)
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as ModelAction.C2B.CancelC2BSub.Response:
                    let paymentSuccessViewModel = PaymentsSuccessViewModel(paymentSuccess: .init(with: payload.data), model)
                    self.link = .successView(paymentSuccessViewModel)

                case let payload as ModelAction.C2B.GetC2BDetail.Response:
                    self.link = .successView(.init(paymentSuccess: .init(operation: nil, parameters: payload.params), model))
                    
                case let payload as ModelAction.Media.CameraPermission.Response:
                    
                    withAnimation {
                        
                        self.bottomSheet = nil
                    }
                    
                    if payload.result {
                        self.bottomSheet = .init(sheetType: .imageCapture(.init(closeAction: { [weak self] image in
                            
                            self?.bottomSheet = nil
                            self?.action.send(UserAccountViewModelAction.SaveAvatarImage(image: image))
                        })))
                        
                    } else {
                        
                        self.alert = .init(title: "Ошибка", message: "Нет доступа к камере", primary: .init(type: .default, title: "Ok", action: { [weak self] in self?.alert = nil}))
                        
                    }
                    
                case let payload as ModelAction.Media.GalleryPermission.Response:
                    
                    withAnimation {
                        
                        self.bottomSheet = nil
                    }
                    
                    if payload.result {
                        
                        self.link = .imagePicker(.init(closeAction: { [weak self] image in
                            
                            self?.action.send(UserAccountViewModelAction.SaveAvatarImage(image: image))
                        }))
                        
                    } else {
                        
                        self.alert = .init(title: "Ошибка", message: "Нет доступа к галереи", primary: .init(type: .default, title: "Ok", action: { [weak self] in self?.alert = nil}))
                    }
                    
                case _ as ModelAction.ClientInfo.Delete.Response:
                    
                    self.link = .deleteUserInfo(.init(model: self.model))
                    
                default:
                    break
                    
                }
                
            }.store(in: &bindings)
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                    
                case _ as PaymentsSuccessAction.Button.Close:
                    self.action.send(PaymentsViewModelAction.Dismiss())
                    
                case _ as UserAccountViewModelAction.CloseLink:
                    link = nil
                    
                case _ as UserAccountViewModelAction.CloseFieldAlert:
                    textFieldAlert = nil
                    
                case _ as UserAccountViewModelAction.AvatarAction:
                    
                    var buttons: [ButtonIconTextView.ViewModel] = []
                    
                    if model.cameraIsAvailable {
                        buttons.append(.init(icon: .init(image: .ic24Camera, style: .original, background: .circleSmall), title: .init(text: "Сделать фото", color: .textSecondary, style: .bold), orientation: .horizontal, action: { [weak self] in
                            self?.bottomSheet = nil
                            self?.model.action.send(ModelAction.Media.CameraPermission.Request())
                        }))
                    }
                    
                    if model.galleryIsAvailable {
                        buttons.append(.init(icon: .init(image: .ic24Image, style: .original, background: .circleSmall), title: .init(text: "Выбрать из галереи", color: .textSecondary, style: .bold), orientation: .horizontal, action: { [weak self] in
                            self?.bottomSheet = nil
                            self?.model.action.send(ModelAction.Media.GalleryPermission.Request())
                        }))
                    }
                    
                    if model.clientPhoto.value != nil {
                        buttons.append(.init(icon: .init(image: .ic24Trash2, style: .original, background: .circleSmall), title: .init(text: "Удалить", color: .textSecondary, style: .bold), orientation: .horizontal, action: { [weak self] in
                            self?.bottomSheet = nil
                            self?.model.action.send(ModelAction.ClientPhoto.Delete())
                        }))
                    }
                    
                    self.bottomSheet = .init(sheetType: .avatarOptions(.init(buttons: buttons)))
                    
                case let payload as UserAccountViewModelAction.SaveAvatarImage:
                    
                    self.bottomSheet = nil
                    
                    guard let image = payload.image?.resizeImageTo(size: .init(width: 100, height: 100)) else { return }
                    guard let photoData = ImageData(with: image) else { return }
                    
                    model.action.send(ModelAction.ClientPhoto.Save(image: photoData))
                    
                case _ as UserAccountViewModelAction.ExitAction:
                    alert = .exit {
                        self.model.auth.value = .unlockRequiredManual
                    }
                    
                case _ as UserAccountViewModelAction.DeleteAction:
                    
                    alert = .init(
                        title: "Удалить учетную запись?", message: "Вы действительно хотите удалить свои данные из Фора-Онлайн?\n\nДля входа в приложение потребуется новая регистрация данных",
                        primary: .init(type: .default, title: "ОК", action: {
                            self.model.action.send(ModelAction.ClientInfo.Delete.Request())
                        }),
                        secondary: .init(type: .cancel, title: "Отмена", action: { }))
                    
                case _ as UserAccountViewModelAction.DeleteInfoAction:
                    
                    bottomSheet = .init(sheetType: .deleteInfo(.exitInfoViewModel))
                
                case let payload as UserAccountViewModelAction.OpenSbpPay:
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) { [weak self] in
                        
                        withAnimation {
                            
                            self?.bottomSheet = .init(sheetType: .sbpay(payload.sbpPay))
                        }
                    }
                    
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
                            title: "Имя", message: "Как к вам обращаться?\n* Имя не должно превышать 15 символов", maxLength: 15,
                            primary: .init(type: .default, title: "ОК", action: { [weak self] text in
                                
                                self?.action.send(UserAccountViewModelAction.CloseFieldAlert())
                                self?.model.action.send(ModelAction.ClientName.Save(name: text))
                                
                            }),
                            secondary: .init(type: .cancel, title: "Отмена", action: { [weak self] _ in
                                self?.action.send(UserAccountViewModelAction.CloseFieldAlert())
                            }))
                        
                    case _ as UserAccountViewModelAction.OpenManagingSubscription:
                        model.action.send(ModelAction.C2B.GetC2BSubscription.Request())
                            
                        let products = self.getSubscriptions(with: model.subscriptions.value?.list)
                        
                        let reducer = TransformingReducer(
                            placeholderText: "Поиск",
                            transform: {
                                .init(
                                    $0.text,
                                    cursorPosition: $0.cursorPosition
                                )
                            }
                        )
                        
                        let emptyTitle = model.subscriptions.value?.emptyList?.compactMap({ $0 }).joined(separator: "\n")
                        let emptySearchTitle = model.subscriptions.value?.emptySearch ?? "Нет совпадений"
                        let titleCondition = (products.count == 0)
                        let emptyViewModel = SubscriptionsViewModel.EmptyViewModel(
                            icon: titleCondition ? Image.ic24Trello : Image.ic24Search,
                            title: titleCondition ? (emptyTitle ?? "Нет совпадений") : emptySearchTitle
                        )
                        
                        link = .managingSubscription(
                            .init(products: products,
                                  searchViewModel: .init(
                                    initialState: .placeholder("Поиск"),
                                    reducer: reducer,
                                    keyboardType: .default
                                  ),
                                  emptyViewModel: emptyViewModel,
                                  configurator: .init(
                                    backgroundColor: .mainColorsGrayLightest
                                ))
                        )
                        
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
                            //TODO: set action
                            break
                            
                        case .notification:
                            
                            self.model.action.send(ModelAction.Settings.UpdateUserSettingPush(userSetting: .init(value: payload.value)))
                        }
                        
                    case let payload as UserAccountViewModelAction.OpenDocument:
                        guard let clientInfo = model.clientInfo.value else { return }
                        switch payload.type {
                            
                        case .passport:
                            self.link = .userDocument(.init(clientInfo: clientInfo, itemType: .passport, dismissAction: {[weak self] in self?.action.send(UserAccountViewModelAction.CloseLink())}))
                            
                        case .inn:
                            guard let inn = clientInfo.inn else { return }
                            let documentInfoViewModel = UserAccountDocumentInfoView.ViewModel(itemType: payload.type, content: inn)
                            bottomSheet = .init(sheetType: .inn(documentInfoViewModel))
                            self.bind(documentInfoViewModel: documentInfoViewModel)
                            
                        case .adressPass:
                            let address = clientInfo.address
                            let documentInfoViewModel = UserAccountDocumentInfoView.ViewModel(itemType: payload.type, content: address)
                            bottomSheet = .init(sheetType: .inn(documentInfoViewModel))
                            self.bind(documentInfoViewModel: documentInfoViewModel)
                            
                        case .adress:
                            guard let addressResidential = clientInfo.addressResidential else { return }
                            let documentInfoViewModel = UserAccountDocumentInfoView.ViewModel(itemType: payload.type, content: addressResidential)
                            bottomSheet = .init(sheetType: .inn(documentInfoViewModel))
                            self.bind(documentInfoViewModel: documentInfoViewModel)
                        }
                        
                    default:
                        break
                        
                    }
                    
                }.store(in: &bindings)
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
    
    
    func getSubscriptions(
        with items: [C2BSubscription.ProductSubscription]?
    ) -> [SubscriptionsViewModel.Product] {
        
        var products: [SubscriptionsViewModel.Product] = []
        
        guard let items else {
            return []
        }
        
        for item in items {
            
            let product = model.allProducts.first(where: { $0.id.description == item.productId })
            
            let subscriptions = item.subscriptions.map({
                
                var image: SubscriptionViewModel.Icon = .default(.ic24ShoppingCart)
                
                let brandIcon = $0.brandIcon
                
                if let icon = model.images.value[brandIcon]?.image {
                    
                    image = .image(icon)
                    
                } else {
                    
                    image = .default(.ic24ShoppingCart)
                    model.action.send(ModelAction.Dictionary.DownloadImages.Request(imagesIds: [brandIcon]))
                    
                }
                
                return ManageSubscriptionsUI.SubscriptionViewModel(
                    token: $0.subscriptionToken,
                    name: $0.brandName,
                    image: image,
                    subtitle: $0.subscriptionPurpose,
                    purposeTitle: $0.cancelAlert,
                    trash: .ic24Trash2,
                    config: .init(
                        headerFont: .textH4M16240(),
                        subtitle: .textBodySR12160()
                    ),
                    onDelete: { token, title in
                        
                        self.alert = .init(
                            title: title,
                            message: nil,
                            primary: .init(
                                type: .cancel, title: "Отмена", action: {}),
                            secondary: .init(type: .default, title: "Отключить", action: {
                                
                                self.model.action.send(ModelAction.C2B.CancelC2BSub.Request(token: token))
                            }))
                    },
                    detailAction: { token in
                        
                        self.model.action.send(ModelAction.C2B.GetC2BDetail.Request(token: token))
                    })
            })
            
            if let product,
               let balance = model.amountFormatted(
                amount: product.balanceValue,
                currencyCode: product.currency,
                style: .fraction
               ),
               let icon = product.smallDesign.image {
                
                if let product = product as? ProductCardData {
                    
                    products.append(.init(
                        image: icon,
                        title: item.productTitle,
                        paymentSystemIcon: nil,
                        name: product.displayName,
                        balance: balance,
                        descriptions: product.description,
                        isLocked: product.isBlocked,
                        subscriptions: subscriptions
                    ))
                    
                } else {
                    
                    products.append(.init(
                        image: icon,
                        title: item.productTitle,
                        paymentSystemIcon: nil,
                        name: product.displayName,
                        balance: balance,
                        descriptions: product.description,
                        isLocked: false,
                        subscriptions: subscriptions
                    ))
                }
            }
        }
        
        return products
    }
}

private extension Alert.ViewModel {
    
    static func exit(
        action: @escaping () -> Void
    ) -> Self {
        
        .init(
            title: "Выход",
            message: "Вы действительно хотите выйти из учетной записи?\nДля повторного входа Вам необходимо будет пройти повторную регистрацию",
            primary: .init(
                type: .default,
                title: "Выход",
                action: action
            ),
            secondary: .init(
                type: .cancel,
                title: "Отмена",
                action: {}
            )
        )
    }
    
    static func delete(
        action: @escaping () -> Void
    ) -> Self {
        
        .init(
            title: "Удалить учетную запись?",
            message: "Вы действительно хотите удалить свои данные из Фора-Онлайн?\n\nДля входа в приложение потребуется новая регистрация данных",
            primary: .init(
                type: .default,
                title: "ОК",
                action: action
            ),
            secondary: .init(
                type: .cancel,
                title: "Отмена",
                action: {}
            )
        )
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
        case deleteUserInfo(DeleteAccountView.DeleteAccountViewModel)
        case imagePicker(ImagePickerViewModel)
        case managingSubscription(SubscriptionsViewModel)
        case successView(PaymentsSuccessViewModel)
    }
    
    struct Sheet: Identifiable {
        
        let id = UUID()
        let sheetType: SheetType
        
        enum SheetType {
            case userDocument(UserDocumentViewModel)
        }
    }
    
    struct BottomSheet: BottomSheetCustomizable {
        
        let id = UUID()
        let sheetType: SheetType
        
        enum SheetType {
            case deleteInfo(UserAccountExitInfoView.ViewModel)
            case inn(UserAccountDocumentInfoView.ViewModel)
            case camera(UserAccountPhotoSourceView.ViewModel)
            case avatarOptions(OptionsButtonsViewComponent.ViewModel)
            case imageCapture(ImageCaptureViewModel)
            case sbpay(SbpPayViewModel)
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
