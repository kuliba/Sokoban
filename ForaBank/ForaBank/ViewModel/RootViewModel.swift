//
//  RootViewModel.swift
//  ForaBank
//
//  Created by Max Gribov on 15.02.2022.
//

import Combine
import Foundation
import PayHub
import SwiftUI

class RootViewModel: ObservableObject, Resetable {
    
    typealias ShowLoginAction = (RootViewModel.RootActions) -> RootViewModelAction.Cover.ShowLogin

    let action: PassthroughSubject<Action, Never> = .init()
    
    @Published private(set) var isTabBarHidden = false
    @Published var selected: TabType
    @Published var alert: Alert.ViewModel?
    @Published private(set) var link: Link?
    
    let mainViewModel: MainViewModel
    let paymentsModel: PaymentsModel
    let chatViewModel: ChatViewModel
    let informerViewModel: InformerView.ViewModel
    
    var coverPresented: RootViewHostingViewController.Cover.Kind?
    
    private let fastPaymentsFactory: FastPaymentsFactory
    private let navigationStateManager: UserAccountNavigationStateManager
    private let productNavigationStateManager: ProductProfileFlowManager

    let model: Model
    private let infoDictionary: [String : Any]?
    private let showLoginAction: ShowLoginAction
    private var bindings = Set<AnyCancellable>()
    private var auithBinding: AnyCancellable?
    
    init(
        fastPaymentsFactory: FastPaymentsFactory,
        navigationStateManager: UserAccountNavigationStateManager,
        productNavigationStateManager: ProductProfileFlowManager,
        mainViewModel: MainViewModel,
        paymentsModel: PaymentsModel,
        chatViewModel: ChatViewModel,
        informerViewModel: InformerView.ViewModel,
        infoDictionary: [String : Any]? = Bundle.main.infoDictionary,
        _ model: Model,
        showLoginAction: @escaping ShowLoginAction
    ) {
        self.fastPaymentsFactory = fastPaymentsFactory
        self.navigationStateManager = navigationStateManager
        self.productNavigationStateManager = productNavigationStateManager
        self.selected = .main
        self.mainViewModel = mainViewModel
        self.paymentsModel = paymentsModel
        self.chatViewModel = chatViewModel
        self.informerViewModel = informerViewModel
        self.model = model
        self.infoDictionary = infoDictionary
        self.showLoginAction = showLoginAction
        
        mainViewModel.rootActions = rootActions
        if case let .legacy(paymentsViewModel) = paymentsModel {
            paymentsViewModel.rootActions = rootActions
        }
        
        bind()
        bindAuth()
        bindTabBar()
    }

    func reset() {
        
        mainViewModel.reset()
        paymentsModel.reset()
        chatViewModel.reset()
    }
    
    func resetLink() {
        
        link = nil
    }
    
    private func bindAuth() {
        
        LoggerAgent.shared.log(level: .debug, category: .ui, message: "bind auth")
        
        auithBinding = model.auth
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] auth in
                
                switch auth {
                case .registerRequired:
                    guard coverPresented != .login else {
                        return
                    }
                    
                    resetRootView()
                    
                    LoggerAgent.shared.log(category: .ui, message: "sent RootViewModelAction.Cover.ShowLogin")
                    
                    action.send(showLoginAction(rootActions))
                    
                case .signInRequired:
                    guard coverPresented != .lock else {
                        return
                    }
                    
                    resetRootView()
                    
                    let lockViewModel = AuthPinCodeViewModel(model, mode: .unlock(attempt: 0, auto: true), rootActions: rootActions)
                    
                    LoggerAgent.shared.log(category: .ui, message: "sent RootViewModelAction.Cover.ShowLock, animated: false")
                    action.send(RootViewModelAction.Cover.ShowLock(viewModel: lockViewModel, animated: false))
                    
                case .unlockRequired:
                    guard coverPresented != .lock else {
                        return
                    }
                    
                    resetRootView()
                    
                    let lockViewModel = AuthPinCodeViewModel(model, mode: .unlock(attempt: 0, auto: true), rootActions: rootActions)
                    
                    LoggerAgent.shared.log(category: .ui, message: "sent RootViewModelAction.Cover.ShowLock, animated: true")
                    action.send(RootViewModelAction.Cover.ShowLock(viewModel: lockViewModel, animated: true))
                    
                case .unlockRequiredManual:
                    guard coverPresented != .lock else {
                        return
                    }
                    
                    resetRootView()
                    
                    let lockViewModel = AuthPinCodeViewModel(model, mode: .unlock(attempt: 0, auto: false), rootActions: rootActions)
                    
                    LoggerAgent.shared.log(category: .ui, message: "sent RootViewModelAction.Cover.ShowLock, animated: true")
                    action.send(RootViewModelAction.Cover.ShowLock(viewModel: lockViewModel, animated: true))
                    
                case .authorized:
                    resetRootView()
                    
                    LoggerAgent.shared.log(category: .ui, message: "sent RootViewModelAction.Cover.Hide")
                    action.send(RootViewModelAction.Cover.Hide())
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) { [unowned self] in
                        
                        guard let clientInformData = self.model.clientInform.value.data?.authorized,
                              let clientInformViewModel = ClientInformViewModel(model: self.model, itemsData: clientInformData)
                        else { return }
                        
                        self.mainViewModel.route.modal = .bottomSheet(.init(type: .clientInform(clientInformViewModel)))
                    }
                }
            }
    }
    
    fileprivate func resetRootView() {
        
        LoggerAgent.shared.log(category: .ui, message: "sent RootViewModelAction.DismissAll")
        action.send(RootViewModelAction.DismissAll())
        
        LoggerAgent.shared.log(category: .ui, message: "sent RootViewModelAction.SwitchTab, type: .main")
        action.send(RootViewModelAction.SwitchTab(tabType: .main))
    }
    
    private func bind() {
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case _ as RootViewModelAction.Appear:
                    LoggerAgent.shared.log(level: .debug, category: .ui, message: "received RootViewModelAction.Appear")
                    bindAuth()
                    
                case let payload as RootViewModelAction.SwitchTab:
                    LoggerAgent.shared.log(level: .debug, category: .ui, message: "received RootViewModelAction.SwitchTab, tab: .\(payload.tabType.rawValue)")
                    withAnimation {
                        selected = payload.tabType
                    }
                    
                case _ as RootViewModelAction.DismissAll:
                    LoggerAgent.shared.log(level: .debug, category: .ui, message: "received RootViewModelAction.DismissAll")
                    reset()
                    model.setPreferredProductID(to: nil)
                    
                case let payload as RootViewModelAction.ShowUserProfile:
                    LoggerAgent.shared.log(level: .debug, category: .ui, message: "received RootViewModelAction.ShowUserProfile")
                    guard let clientInfo = model.clientInfo.value else {
                        return
                    }
                    link = .userAccount(.init(
                        navigationStateManager: navigationStateManager,
                        model: model,
                        clientInfo: clientInfo,
                        dismissAction: { [weak self] in
                            
                            self?.action.send(RootViewModelAction.CloseLink())
                        },
                        action: UserAccountViewModelAction.OpenSbpPay(
                            sbpPay: .init(
                                model,
                                personAgreements: payload.conditions,
                                rootActions: rootActions,
                                tokenIntent: payload.tokenIntent
                            ))
                    ))
                
                case _ as RootViewModelAction.CloseAlert:
                    LoggerAgent.shared.log(level: .debug, category: .ui, message: "received RootViewModelAction.CloseAlert")
                    alert = nil
                    
                case _ as RootViewModelAction.CloseLink:
                    LoggerAgent.shared.log(level: .debug, category: .ui, message: "received RootViewModelAction.CloseLink")
                    link = nil
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
        
        model.action
            .compactMap { $0 as? ModelAction.DeepLink.Process }
            .map(\.type)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] deepLink in
                
                switch deepLink {
                case let .me2me(bankId):
                    self.action.send(ModelAction.Consent.Me2MeDebit.Request(bankid: bankId))
                    
                case let .c2b(url):
                    let operationViewModel = PaymentsViewModel(
                        source: .c2b(url),
                        model: model,
                        closeAction: { [weak self] in
                            
                            self?.action.send(RootViewModelAction.CloseLink())
                        }
                    )
                    self.link = .payments(operationViewModel)
                    
                case let .c2bSubscribe(url):
                    let operationViewModel = PaymentsViewModel(
                        source: .c2bSubscribe(url),
                        model: model,
                        closeAction: { [weak self] in
                            
                            self?.action.send(RootViewModelAction.CloseLink())
                        }
                    )
                    self.link = .payments(operationViewModel)
                    
                case let .sbpPay(tokenIntent):
                    self.model.action.send(ModelAction.SbpPay.Register.Request(tokenIntent: tokenIntent))
                    self.model.action.send(ModelAction.FastPaymentSettings.ContractFindList.Request())
                }
                
                model.action.send(ModelAction.DeepLink.Clear())
                
            }.store(in: &bindings)
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [weak self] action in
                
                guard let self else { return }
                
                switch action {
                case let payload as ModelAction.Notification.Transition.Process:
                    
                    switch payload.transition {
                    case .history:
                        self.rootActions.dismissAll()
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(800)) {
                            
                            let messagesHistoryViewModel: MessagesHistoryViewModel = .init(model: self.model, closeAction: {[weak self] in self?.action.send(RootViewModelAction.CloseLink()) })
                            self.link = .messages(messagesHistoryViewModel)
                            self.model.action.send(ModelAction.Notification.Transition.Clear())
                        }
                        
                    case .me2me(let requestMeToMeModel):
                        link = .me2me(requestMeToMeModel)
                        self.model.action.send(ModelAction.Notification.Transition.Clear())
                    }
                    
                case let payload as ModelAction.AppVersion.Response:
                    
                    withAnimation {
                        
                        switch payload.result {
                        case let .success(appInfo):
                            LoggerAgent.shared.log(level: .debug, category: .ui, message: "received ModelAction.AppVersion.Response, success, info: \(appInfo)")
                            
                            if let appVersion = self.infoDictionary?["CFBundleShortVersionString"] as? String {
                                
                                let compareVersion = appInfo.version.compareVersion(to: appVersion)
                                
                                switch compareVersion {
                                case .orderedDescending:
                                    
                                    self.alert = self.createAlertAppVersion(appInfo)
                                    
                                default:
                                    break
                                }
                            }
                            
                        case let .failure(error):
                            LoggerAgent.shared.log(level: .error, category: .ui, message: "received ModelAction.AppVersion.Response, failure, error: \(error.localizedDescription)")
                        }
                    }
                case let payload as ModelAction.Consent.Me2MeDebit.Response:
                    switch payload.result {
                    case .success(let consentData):
                        LoggerAgent.shared.log(level: .debug, category: .ui, message: "received ModelAction.Consent.Me2MeDebit.Response, success, consentData: \(consentData)")
                        
                        self.action.send(RootViewModelAction.DismissAll())
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                            
                            self.link = .me2me(.init(model: consentData.getConcentLegacy()))
                        }
                        
                    case .failure(let error):
                        LoggerAgent.shared.log(level: .error, category: .ui, message: "received ModelAction.Consent.Me2MeDebit.Response, failure, error: \(error.localizedDescription)")
                    }
                    
                case let payload as ModelAction.SbpPay.Register.Response:
                    switch payload.result {
                    case .success:
                        LoggerAgent.shared.log(level: .debug, category: .ui, message: "received ModelAction.SbpPay.Register.Response, success")
                        self.model.action.send(ModelAction.GetPersonAgreement.Request(
                            tokenIntent: payload.tokenIntent,
                            system: .sbp,
                            type: nil
                        ))
                    case .failed:
                        LoggerAgent.shared.log(level: .error, category: .ui, message: "received ModelAction.SbpPay.Register.Response, failed")
                    }
                case let payload as ModelAction.GetPersonAgreement.Response:
                    switch payload.result {
                    case let .success(personAgreement):
                        LoggerAgent.shared.log(level: .debug, category: .ui, message: "received ModelAction.GetPersonAgreement.Response, success, personAgreement: \(personAgreement)")
                        
                        self.action.send(RootViewModelAction.DismissAll())
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(800)) {
                            
                            self.action.send(RootViewModelAction.ShowUserProfile(
                                tokenIntent: payload.tokenIntent,
                                conditions: personAgreement
                            ))
                        }
                        
                    case let .failure(error):
                        LoggerAgent.shared.log(level: .error, category: .ui, message: "received ModelAction.GetPersonAgreement.Response, failure, error: \(error.localizedDescription)")
                    }
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
    }
    
    lazy var rootActions: RootViewModel.RootActions = {
        
        let dismissCover: (() -> Void) = { [weak self] in
            
            self?.action.send(RootViewModelAction.Cover.Hide())
        }
        
        let spinnerShow: (() -> Void) = { [weak self] in
            
            self?.action.send(RootViewModelAction.Spinner.Show(viewModel: .init()))
        }
        
        let spinnerHide: (() -> Void) = { [weak self] in
            
            self?.action.send(RootViewModelAction.Spinner.Hide())
        }
        
        let switchTab: ((RootViewModel.TabType) -> Void) = { [weak self] tabType in
            
            self?.action.send(RootViewModelAction.SwitchTab(tabType: tabType))
        }
        
        let dismissAll: (() -> Void) = { [weak self] in
            
            self?.action.send(RootViewModelAction.DismissAll())
        }
        
        return .init(dismissCover: dismissCover, spinner: .init(show: spinnerShow, hide: spinnerHide), switchTab: switchTab, dismissAll: dismissAll)
    }()
    
    func createAlertAppVersion(
        _ appInfo: AppInfo
    ) -> Alert.ViewModel {
        
        .init(
            title: "Новая версия",
            message: "Доступна новая версия \(appInfo.version).",
            primary: .init(type: .default, title: "Не сейчас", action: {}),
            secondary: .init(
                type: .default,
                title: "Обновить",
                action: {
                    guard let url = URL(string: "\(appInfo.trackViewUrl)") else {
                        return
                    }
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    
                })
        )
    }
    
    private func bindTabBar() {
        
        let mainViewModelHasDestination = mainViewModel.$route
            .map { $0.destination != nil }
        
        let paymentsViewModelHasDestination = paymentsModel.hasDestination
        
        mainViewModelHasDestination
            .combineLatest(paymentsViewModelHasDestination)
            .map { $0 || $1 }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .assign(to: &$isTabBarHidden)
    }
}

private extension Model {
    
    var eventPublishers: AuthLoginViewModel.EventPublishers {
        
        .init(
            clientInformMessage: clientInform
                .filter { [self] _ in
                    
                    !clientInformStatus.isShowNotAuthorized
                }
                .compactMap(\.data?.notAuthorized)
                .handleEvents(receiveOutput: { [self] _ in
                    
                    clientInformStatus.isShowNotAuthorized = true
                })
                .eraseToAnyPublisher(),
            
            checkClientResponse: action
                .compactMap { $0 as? ModelAction.Auth.CheckClient.Response }
                .eraseToAnyPublisher(),
            
            catalogProducts: catalogProducts
                .eraseToAnyPublisher(),
            
            sessionStateFcmToken: sessionState
                .combineLatest(fcmToken)
                .eraseToAnyPublisher()
        )
    }
    
    func register(cardNumber: String) -> Void {
        
        LoggerAgent.shared.log(category: .ui, message: "send ModelAction.Auth.CheckClient.Request number: ...\(cardNumber.suffix(4))")
        
        action.send(ModelAction.Auth.CheckClient.Request(number: cardNumber))
    }
    
    func catalogProduct(
        for request: AuthLoginViewModel.EventHandlers.Request
    ) -> CatalogProductData? {
        
        switch request {
        case let .id(id):
            return catalogProducts.value.first {
                $0.id == id
            }
            
        case let .tarif(tarif, type: type):
            return catalogProducts.value.first {
                $0.tariff == tarif &&
                $0.productType == type
            }
        }
    }
}

// MARK: - Types

extension RootViewModel {
    
    enum TabType: String, Hashable {
        
        case main
        case payments
        case history
        case chat
        
        var name: String {
            
            switch self {
            case .main: return "Главный"
            case .payments: return "Платежи"
            case .history: return "История"
            case .chat: return "Чат"
            }
        }
    }
    
    struct RootActions {
        
        let dismissCover: () -> Void
        let spinner: Spinner
        let switchTab: (RootViewModel.TabType) -> Void
        let dismissAll: () -> Void
        
        struct Spinner {
            
            let show: () -> Void
            let hide: () -> Void
        }
    }
    
    enum Link {
        
        case messages(MessagesHistoryViewModel)
        case me2me(RequestMeToMeModel)
        case userAccount(UserAccountViewModel)
        case payments(PaymentsViewModel)
    }
    
    enum PaymentsModel {
        
        case legacy(PaymentsTransfersViewModel)
        case v1(PaymentsTransfersBinder)
    }
}

extension RootViewModel.PaymentsModel: Resetable {
    
    func reset() {
        
        switch self {
        case let .legacy(paymentsTransfersViewModel):
            paymentsTransfersViewModel.reset()
            
        case let .v1(paymentsTransfersModel):
#warning("unimplemented")
            break
        }
    }
    
    var hasDestination: AnyPublisher<Bool, Never> {
        
        switch self {
        case let .legacy(paymentsTransfersViewModel):
            return paymentsTransfersViewModel.$route
                .map { $0.destination != nil }
                .eraseToAnyPublisher()
            
        case let .v1(binder):
            return binder.hasDestination
        }
    }
}

extension PaymentsTransfersBinder {
    
    var hasDestination: AnyPublisher<Bool, Never> {
        
        Publishers.Merge(
            content.categoryPicker.hasDestination,
            //     content.operationPicker,
            content.toolbar.hasDestination
            //   flow.$state
        ) 
        .scan(false) { $0 || $1 }
        .removeDuplicates()
        .eraseToAnyPublisher()
    }
}

private extension CategoryPickerSectionBinder {
    
    var hasDestination: AnyPublisher<Bool, Never> {
        
        flow.$state.map(\.hasDestination).eraseToAnyPublisher()
    }
}

private extension CategoryPickerSectionFlowState {
    
    var hasDestination: Bool { destination != nil }
}

private extension OperationPickerBinder {
    
    var hasDestination: AnyPublisher<Bool, Never> {
        
       // flow.$state.map(\.hasDestination)
        Just(false)
        .eraseToAnyPublisher()
    }
}

private extension PaymentsTransfersToolbarBinder {
    
    var hasDestination: AnyPublisher<Bool, Never> {
        
        flow.$state.map(\.hasDestination).eraseToAnyPublisher()
    }
}

private extension PaymentsTransfersToolbarFlowState {
    
    var hasDestination: Bool { navigation != nil }
}

extension RootViewModel.RootActions {
    
    func showSpinner(_ isShowing: Bool) {
        
        if isShowing {
            spinner.show()
        } else {
            spinner.hide()
        }
    }
}

//MARK: - Action

enum RootViewModelAction {
    
    struct Appear: Action {}
    
    enum Cover {
        
        struct ShowLogin: Action {
            
            let viewModel: ComposedLoginViewModel
        }
        
        struct ShowLock: Action {
            
            let viewModel: AuthPinCodeViewModel
            let animated: Bool
        }
        
        struct Hide: Action {}
    }
    
    enum Spinner {
        
        struct Show: Action {
            
            let viewModel: SpinnerView.ViewModel
        }
        
        struct Hide: Action {}
    }
    
    struct ShowPermissions: Action {
        
        let sensorType: BiometricSensorType
    }
    
    struct SwitchTab: Action {
        
        let tabType: RootViewModel.TabType
    }
    
    struct DismissAll: Action {}
    
    struct CloseAlert: Action {}
    
    struct CloseLink: Action {}
    
    struct ShowUserProfile: Action {
        
        let tokenIntent: String
        let conditions: [PersonAgreement]
    }
}
