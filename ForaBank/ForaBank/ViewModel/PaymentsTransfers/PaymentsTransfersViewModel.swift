//
//  PaymentsTransfersViewModel.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 09.05.2022.
//

import Combine
import ForaTools
import PickerWithPreviewComponent
import SberQR
import SwiftUI
import OperatorsListComponents

class PaymentsTransfersViewModel: ObservableObject, Resetable {
    
    typealias TransfersSectionVM = PTSectionTransfersView.ViewModel
    typealias PaymentsSectionVM = PTSectionPaymentsView.ViewModel
    typealias MakeFlowManger = (RootViewModel.RootActions.Spinner?) -> PaymentsTransfersFlowManager
    
    let action: PassthroughSubject<Action, Never> = .init()
    
    lazy var userAccountButton: MainViewModel.UserAccountButtonViewModel = .init(
        logo: MainViewModel.logo,
        name: "",
        avatar: nil,
        action: { [weak self] in
            self?.action.send(PaymentsTransfersViewModelAction
                .ButtonTapped.UserAccount())
        }
    )
    
    @Published var sections: [PaymentsTransfersSectionViewModel]
    @Published var navButtonsRight: [NavigationBarButtonViewModel]
    
    @Published var route: Route
    @Published var fullCover: FullCover?
    
    private let routeSubject = PassthroughSubject<Route, Never>()
    
    let mode: Mode
    var rootActions: RootViewModel.RootActions?
    
    private let model: Model
    private let makeFlowManager: MakeFlowManger
    private let userAccountNavigationStateManager: UserAccountNavigationStateManager
    private let sberQRServices: SberQRServices
    private let qrViewModelFactory: QRViewModelFactory
    private let paymentsTransfersFactory: PaymentsTransfersFactory
    private var bindings = Set<AnyCancellable>()
    private let scheduler: AnySchedulerOfDispatchQueue
    
    init(
        model: Model,
        makeFlowManager: @escaping MakeFlowManger,
        userAccountNavigationStateManager: UserAccountNavigationStateManager,
        sberQRServices: SberQRServices,
        qrViewModelFactory: QRViewModelFactory,
        paymentsTransfersFactory: PaymentsTransfersFactory,
        isTabBarHidden: Bool = false,
        mode: Mode = .normal,
        route: Route = .empty,
        scheduler: AnySchedulerOfDispatchQueue = .main
    ) {
        self.navButtonsRight = []
        self.sections = paymentsTransfersFactory.makeSections()
        self.mode = mode
        self.model = model
        self.userAccountNavigationStateManager = userAccountNavigationStateManager
        self.sberQRServices = sberQRServices
        self.qrViewModelFactory = qrViewModelFactory
        self.paymentsTransfersFactory = paymentsTransfersFactory
        self.route = route
        self.makeFlowManager = makeFlowManager
        self.scheduler = scheduler
        self.navButtonsRight = createNavButtonsRight()
        
        bind()
        bindSections(sections)
        
        routeSubject
            .receive(on: scheduler)
            .assign(to: &$route)
        
        LoggerAgent.shared.log(level: .debug, category: .ui, message: "PaymentsTransfersViewModel initialized")
    }
    
    init(
        sections: [PaymentsTransfersSectionViewModel],
        model: Model,
        makeFlowManager: @escaping MakeFlowManger,
        userAccountNavigationStateManager: UserAccountNavigationStateManager,
        sberQRServices: SberQRServices,
        qrViewModelFactory: QRViewModelFactory,
        paymentsTransfersFactory: PaymentsTransfersFactory,
        navButtonsRight: [NavigationBarButtonViewModel],
        mode: Mode = .normal,
        route: Route = .empty,
        scheduler: AnySchedulerOfDispatchQueue = .main
    ) {
        self.sections = sections
        self.mode = mode
        self.model = model
        self.route = route
        self.makeFlowManager = makeFlowManager
        self.userAccountNavigationStateManager = userAccountNavigationStateManager
        self.sberQRServices = sberQRServices
        self.qrViewModelFactory = qrViewModelFactory
        self.paymentsTransfersFactory = paymentsTransfersFactory
        self.navButtonsRight = navButtonsRight
        self.scheduler = scheduler
        
        LoggerAgent.shared.log(level: .debug, category: .ui, message: "PaymentsTransfersViewModel initialized")
    }
    
    deinit {
        
        LoggerAgent.shared.log(level: .debug, category: .ui, message: "PaymentsTransfersViewModel deinitialized")
    }
}

extension PaymentsTransfersViewModel {
    
    typealias State = PaymentsTransfersViewModel.Route
    typealias Event = PaymentsTransfersFlowEvent<LastPayment, Operator, Service>
    typealias Effect = PaymentsTransfersFlowEffect<LastPayment, Operator, Service>
    
    typealias LastPayment = UtilityPaymentLastPayment
    typealias Operator = UtilityPaymentOperator
    typealias Service = UtilityService
}

extension PaymentsTransfersViewModel {
    
    func event(_ event: Event) {
        
        let closeAction: () -> Void = { [weak self] in
            
            self?.event(.dismiss(.destination))
        }
        let notify: (AnywayTransactionStatus?) -> Void = { [weak self] in
            
            self?.event(.utilityFlow(.payment(.notified($0))))
        }
        
        let flowManager = makeFlowManager(rootActions?.spinner)
        let reduce = flowManager.makeReduce(closeAction, notify)
        let (route, effect) = reduce(route, event)
        
        if let outside = route.outside {
            handleOutside(outside)
        } else if let legacy = route.legacy {
            handle(legacy)
        } else {
            routeSubject.send(route)
            effect.map(handleEffect(_:))
        }
    }
    
    func reset() {
        
        routeSubject.send(.empty)
        fullCover = nil
    }
    
    func dismiss() {
        
        self.event(.dismiss(.destination))
    }
    
    func openScanner() {
        
        let qrModel = qrViewModelFactory.makeQRScannerModel()
        let cancellable = bind(qrModel)
        
        self.route.modal = .fullScreenSheet(.init(
            type: .qrScanner(.init(
                model: qrModel,
                cancellable: cancellable
            ))
        ))
    }
    
    func getMosParkingPickerData() async throws -> MosParkingPickerData {
        
        let (_, data) = try await model.getMosParkingListData()
        let (state, options, refillID) = try MosParkingDataMapper.map(data: data)
        
        return .init(
            state: state,
            options: options,
            refillID: refillID
        )
    }
}

extension Model {
    
    func getMosParkingListData() async throws -> (serial: String, data: [MosParkingData]) {
        
        guard let token else {
            
            throw Payments.Error.notAuthorized
        }
        
        typealias GetMosParkingList = ServerCommands.DictionaryController.GetMosParkingList
        typealias MosParkingListData = ServerCommands.DictionaryController.GetMosParkingList.Response.MosParkingListData
        
        let command = GetMosParkingList(token: token, serial: nil)
        let listData: MosParkingListData = try await serverAgent.executeCommand(command: command)
        
        return (listData.serial, listData.mosParkingList)
    }
}

private extension Model {
    
    // TODO: rename `makeTransportPaymentsViewModel`
    // TODO: rename `TransportPaymentsViewModel` to reflect generic nature of the component that gets operators and last operations for a given type
    // TODO: `substitutingAvtodors` from reuse as generic case for any PTSectionPaymentsView.ViewModel.PaymentsType
    func makeTransportPaymentsViewModel(
        type: PTSectionPaymentsView.ViewModel.PaymentsType,
        handleError: @escaping (String) -> Void
    ) -> TransportPaymentsViewModel? {
        
        guard let anywayOperators = dictionaryAnywayOperators(),
              let operatorValue = Payments.operatorByPaymentsType(type)
        else { return nil }
        
        let operators = anywayOperators
            .filter { $0.parentCode == operatorValue.rawValue }
        // TODO: Remove filter after GIBDD & MosParking fix
        // .filter { $0.code != Purefs.iForaGibdd && $0.code != Purefs.iForaMosParking  }
            .sorted { $0.name.lowercased() < $1.name.lowercased() }
            .sorted { $0.name.caseInsensitiveCompare($1.name) == .orderedAscending }
        // TODO: `replacingAvtodors` from reuse as generic case for any PTSectionPaymentsView.ViewModel.PaymentsType
            .replacingAvtodors(with: avtodorGroup)
        
        let latestPayments = makeLatestPaymentsSectionViewModel(forType: type)
        
        return .init(
            operators: operators,
            latestPayments: latestPayments,
            makePaymentsViewModel: makePaymentsViewModel(source:),
            handleError: handleError
        )
    }
    
    func makeLatestPaymentsSectionViewModel(
        forType type: PTSectionPaymentsView.ViewModel.PaymentsType
    ) -> PaymentsServicesLatestPaymentsSectionViewModel {
        
        let kind = LatestPaymentData.Kind(rawValue: type.rawValue)
        let including = Set([kind].compactMap { $0 })
        
        return .init(model: self, including: including)
    }
}

extension Array where Element == OperatorGroupData.OperatorData {
    
    func replacingAvtodors(
        with avtodor: OperatorGroupData.OperatorData?
    ) -> Self {
        
        guard let avtodor else { return self }
        
        var copy = self
        
        copy.removeAll { $0.synonymList == [TaxCodes.avtodor] }
        copy.insert(avtodor, at: 0)
        
        return copy
    }
}

private extension Model {
    
    var avtodorGroup: OperatorGroupData.OperatorData? {
        
        guard let avtodorContract = dictionaryAnywayOperator(for: Purefs.avtodorContract)
        else { return nil }
        
        return .init(
            city: avtodorContract.city,
            code: Purefs.avtodorGroup,
            isGroup: true,
            logotypeList: avtodorContract.logotypeList,
            name: .avtodorGroupTitle,
            parameterList: avtodorContract.parameterList,
            parentCode: Purefs.transport,
            region: avtodorContract.region,
            synonymList: []
        )
    }
}

private extension PaymentsTransfersViewModel {
    
    func handle(latestPayment: LatestPaymentData) {
        
        switch latestPayment.type {
        case .internet,
                .service,
                .mobile,
                .outside,
                .phone,
                .transport,
                .taxAndStateService:
            
            let paymentsViewModel = PaymentsViewModel(
                source: .latestPayment(latestPayment.id),
                model: model
            ) { [weak self] in
                
                self?.event(.dismiss(.destination))
            }
            
            bind(paymentsViewModel)
            
            self.action.send(DelayWrappedAction(
                delayMS: 300,
                action: PaymentsTransfersViewModelAction.Show.Payment(viewModel: paymentsViewModel))
            )
            
        default: //error matching
            route.modal = .bottomSheet(.init(type: .exampleDetail(latestPayment.type.rawValue))) //TODO:
        }
    }
}

// MARK: - Types

extension PaymentsTransfersViewModel {
    
    enum Mode {
        
        /// view presented in main tab view
        case normal
        
        /// view presented in navigation stack
        case link
    }
    
    struct Route {
        
        var destination: Link?
        var modal: Modal?
        
        /// - Note: not ideal, but modelling `Route` as an enum to remove impossible states
        /// would lead to significant complications
        var outside: Outside?
        
        /// - Note: moving some of the existing code into the reducer is beyond trivial, so this field is used to get state changing mechanics back to view model
        var legacy: PaymentTriggerState.Legacy?
        
        enum Outside { case chat, main }
        
        static var empty: Self { .init(destination: nil, modal: nil) }
    }
    
    enum Modal {
        
        case alert(Alert.ViewModel)
        case serviceAlert(ServiceFailureAlert)
        case bottomSheet(BottomSheet)
        case fullScreenSheet(FullScreenSheet)
        case sheet(Sheet)
    }
    
    struct BottomSheet: BottomSheetCustomizable {
        
        let id = UUID()
        let type: Kind
        
        let isUserInteractionEnabled: CurrentValueSubject<Bool, Never> = .init(true)
        
        var keyboardOffsetMultiplier: CGFloat {
            
            switch type {
            case .meToMe: return 1
            default: return 0
            }
        }
        
        var animationSpeed: Double {
            
            switch type {
            case .meToMe: return 0.4
            default: return 0.5
            }
        }
        
        enum Kind {
            
            case exampleDetail(String)
            case meToMe(PaymentsMeToMeViewModel)
        }
    }
    
    struct Sheet: Identifiable {
        
        let id = UUID()
        let type: Kind
        
        enum Kind {
            
            case meToMe(PaymentsMeToMeViewModel)
            case successMeToMe(PaymentsSuccessViewModel)
            case transferByPhone(TransferByPhoneViewModel)
            case anotherCard(AnotherCardViewModel)
            case fastPayment(ContactsViewModel)
            case country(ContactsViewModel)
        }
    }
    
    struct FullCover: Identifiable {
        
        let id = UUID()
        let type: Kind
        
        enum Kind {
            case successMeToMe(PaymentsSuccessViewModel)
        }
    }
    
    enum Link: Identifiable {
        
        case exampleDetail(String)
        case userAccount(UserAccountViewModel)
        case mobile(MobilePayViewModel)
        case phone(PaymentByPhoneViewModel)
        case payments(PaymentsViewModel)
        case serviceOperators(OperatorsViewModel)
        case internetOperators(OperatorsViewModel)
        case transportOperators(OperatorsViewModel)
        case service(OperatorsViewModel)
        case internet(OperatorsViewModel)
        case transport(OperatorsViewModel)
        case template(TemplatesListViewModel)
        case country(CountryPaymentView.ViewModel)
        case currencyWallet(CurrencyWalletViewModel)
        case failedView(QRFailedViewModel)
        case c2b(C2BViewModel)
        case searchOperators(QRSearchOperatorViewModel)
        case operatorView(InternetTVDetailsViewModel)
        case paymentsServices(PaymentsServicesViewModel)
        case transportPayments(TransportPaymentsViewModel)
        case productProfile(ProductProfileViewModel)
        case openDeposit(OpenDepositDetailViewModel)
        case sberQRPayment(SberQRConfirmPaymentViewModel)
        case openDepositsList(OpenDepositListViewModel)
        case utilityPayment(UtilityFlowState)
        case servicePayment(UtilityServicePaymentFlowState)
        
        typealias UtilityFlowState = UtilityPaymentFlowState<UtilityPaymentOperator, UtilityService, UtilityPrepaymentViewModel>
    }
    
    struct FullScreenSheet: Identifiable, Equatable {
        
        let id = UUID()
        let type: Kind
        
        enum Kind {
            
            case qrScanner(Node<QRModel>)
            case paymentCancelled(expired: Bool)
            case success(PaymentsSuccessViewModel)
        }
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.id == rhs.id
        }
    }
}

// MARK: - Properties

extension PaymentsTransfersViewModel.Modal {
    
    var alert: Alert.ViewModel? {
        guard case let .alert(alert) = self
        else { return nil }
        
        return alert
    }
    
    var serviceAlert: ServiceFailureAlert? {
        guard case let .serviceAlert(serviceAlert) = self
        else { return nil }
        
        return serviceAlert
    }
    
    var bottomSheet: PaymentsTransfersViewModel.BottomSheet? {
        guard case let .bottomSheet(bottomSheet) = self
        else { return nil }
        
        return bottomSheet
    }
    
    var fullScreenSheet: PaymentsTransfersViewModel.FullScreenSheet? {
        guard case let .fullScreenSheet(fullScreenSheet) = self
        else { return nil }
        
        return fullScreenSheet
    }
    
    var sheet: PaymentsTransfersViewModel.Sheet? {
        guard case let .sheet(sheet) = self
        else { return nil }
        
        return sheet
    }
}

extension PaymentsTransfersViewModel.Link {
    
    var id: Case {
        
        switch self {
        case .exampleDetail:
            return .exampleDetail
        case .userAccount:
            return .userAccount
        case .mobile:
            return .mobile
        case .phone:
            return .phone
        case .payments:
            return .payments
        case .serviceOperators:
            return .serviceOperators
        case .internetOperators:
            return .internetOperators
        case .transportOperators:
            return .transportOperators
        case .service:
            return .service
        case .internet:
            return .internet
        case .transport:
            return .transport
        case .template:
            return .template
        case .country:
            return .country
        case .currencyWallet:
            return .currencyWallet
        case .failedView:
            return .failedView
        case .c2b:
            return .c2b
        case .searchOperators:
            return .searchOperators
        case .operatorView:
            return .operatorView
        case .paymentsServices:
            return .paymentsServices
        case .transportPayments:
            return .transportPayments
        case .productProfile:
            return .productProfile
        case .openDeposit:
            return .openDeposit
        case .openDepositsList:
            return .openDepositsList
        case .sberQRPayment:
            return .sberQRPayment
        case .utilityPayment:
            return .utilityPayment
        case .servicePayment:
            return .servicePayment
        }
    }
    
    enum Case {
        case exampleDetail
        case userAccount
        case mobile
        case phone
        case payments
        case serviceOperators
        case internetOperators
        case transportOperators
        case service
        case internet
        case transport
        case template
        case country
        case currencyWallet
        case failedView
        case c2b
        case searchOperators
        case operatorView
        case paymentsServices
        case transportPayments
        case productProfile
        case openDeposit
        case openDepositsList
        case sberQRPayment
        case utilityPayment
        case servicePayment
    }
}

// MARK: - Action

enum PaymentsTransfersViewModelAction {
    
    enum ButtonTapped {
        
        struct UserAccount: Action {}
        
        struct Scanner: Action {}
    }
    
    enum Close {
        
        struct BottomSheet: Action {}
        
        struct FullCover: Action {}
        
        struct Link: Action {}
        
        struct DismissAll: Action {}
    }
    
    struct OpenQr: Action {}
    
    enum Show {
        
        struct ProductProfile: Action {
            
            let productId: ProductData.ID
        }
        
        struct Alert: Action {
            
            let title: String
            let message: String
        }
        
        struct Payment: Action {
            
            let viewModel: PaymentsViewModel
        }
        
        struct Requisites: Action {
            
            let qrCode: QRCode
        }
        
        struct Contacts: Action {}
        
        struct Countries: Action {}
        
        struct OpenDeposit: Action {}
    }
    
    struct ViewDidApear: Action {}
}

// MARK: - Helpers

private extension PaymentsTransfersViewModel {
    
    private func makeUtilitiesViewModel(
        for type: PTSectionPaymentsView.ViewModel.PaymentsType
    ) {
        event(.paymentButtonTapped(.utilityService(
            makeUtilitiesPayload(forType: type)
        )))
    }
    
    private func handleEffect(
        _ effect: Effect
    ) {
        rootActions?.spinner.show()
        
        let flowManager = makeFlowManager(rootActions?.spinner)
        flowManager.handleEffect(effect) { [weak self] in
            
            self?.rootActions?.spinner.hide()
            self?.event($0)
            _ = flowManager
        }
    }
    
    private func handleOutside(
        _ outside: Route.Outside
    ) {
        rootActions?.spinner.show()
        reset()
        
        delay(for: .milliseconds(300)) { [weak self] in
            
            switch outside {
            case .chat: self?.rootActions?.switchTab(.chat)
            case .main: self?.rootActions?.switchTab(.main)
            }
            
            self?.rootActions?.spinner.hide()
        }
    }
    
    private func handle(
        _ legacy: PaymentTriggerState.Legacy
    ) {
        switch legacy {
        case let .latestPayment(latestPayment):
            handle(latestPayment: latestPayment)
        }
    }
    
    private func delay(
        for timeout: DispatchTimeInterval,
        _ action: @escaping () -> Void
    ) {
        scheduler.delay(for: timeout, action)
    }
}

extension AnySchedulerOfDispatchQueue {
    
    func delay(
        for timeout: DispatchTimeInterval,
        _ action: @escaping () -> Void
    ) {
        schedule(after: .init(.now() + timeout), action)
    }
}

// MARK: - Bindings

private extension PaymentsTransfersViewModel {
    
    private func bind() {
        
        action
            .receive(on: scheduler)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as PaymentsTransfersViewModelAction.Show.ProductProfile:
                    showProductProfile(payload.productId)
                    
                case _ as PaymentsTransfersViewModelAction.Show.OpenDeposit:
                    showOpenDeposit()
                    
                case _ as PaymentsTransfersViewModelAction.ButtonTapped.UserAccount:
                    handleUserAccountButtonTapped()
                    
                case _ as PaymentsTransfersViewModelAction.ButtonTapped.Scanner:
                    // на экране платежей верхний переход
                    self.openScanner()
                    
                case _ as PaymentsTransfersViewModelAction.Close.BottomSheet:
                    event(.dismiss(.modal))
                    
                case _ as PaymentsTransfersViewModelAction.Close.FullCover:
                    fullCover = nil
                    
                case _ as PaymentsTransfersViewModelAction.Close.Link:
                    event(.dismiss(.destination))
                    
                case _ as PaymentsTransfersViewModelAction.Close.DismissAll:
                    
                    withAnimation {
                        NotificationCenter.default.post(name: .dismissAllViewAndSwitchToMainTab, object: nil)
                    }
                    
                case _ as PaymentsTransfersViewModelAction.ViewDidApear:
                    model.action.send(ModelAction.Contacts.PermissionStatus.Request())
                    
                case let payload as PaymentsTransfersViewModelAction.Show.Requisites:
                    showRequisites(qrCode: payload.qrCode)
                    
                default:
                    break
                }
            }
            .store(in: &bindings)
        
        action
            .compactMap { $0 as? PaymentsTransfersViewModelAction.Show.Alert }
            .receive(on: scheduler)
            .sink { [unowned self] in
                
                self.route.modal = .alert(.init(
                    title: $0.title,
                    message: $0.message,
                    primary: .init(
                        type: .default,
                        title: "Ок",
                        action: {}
                    )
                ))
            }
            .store(in: &bindings)
        
        action
            .compactMap { $0 as? PaymentsTransfersViewModelAction.Show.Payment }
            .map(\.viewModel)
            .receive(on: scheduler)
            .sink { [unowned self] in
                
                self.route.destination = .payments($0)
            }
            .store(in: &bindings)
        
        action
            .compactMap { $0 as? PaymentsTransfersViewModelAction.Show.Contacts }
            .receive(on: scheduler)
            .sink { [unowned self] _ in
                
                let contactsViewModel = model.makeContactsViewModel(forMode: .fastPayments(.contacts))
                bind(contactsViewModel)
                
                route.modal = .sheet(.init(type: .fastPayment(contactsViewModel)))
            }
            .store(in: &bindings)
        
        action
            .compactMap{ $0 as? PaymentsTransfersViewModelAction.Show.Countries }
            .receive(on: scheduler)
            .sink { [unowned self] _ in
                
                let contactsViewModel = model.makeContactsViewModel(forMode: .abroad)
                bind(contactsViewModel)
                
                route.modal = .sheet(.init(type: .country(contactsViewModel)))
            }
            .store(in: &bindings)
        
        action
            .compactMap { $0 as? DelayWrappedAction }
            .flatMap {
                
                Just($0.action)
                    .delay(for: .milliseconds($0.delayMS), scheduler: DispatchQueue.main)
                
            }
            .sink { [weak self] in self?.action.send($0) }
            .store(in: &bindings)
        
        model.clientInfo
            .combineLatest(model.clientPhoto, model.clientName)
            .receive(on: scheduler)
            .sink { [unowned self] clientData in
                
                userAccountButton.update(
                    clientInfo: clientData.0,
                    clientPhoto: clientData.1,
                    clientName: clientData.2
                )
            }
            .store(in: &bindings)
        
            model.updateInfo
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in self?.updateSections($0) }
                .store(in: &bindings)
        
    }
    
    func updateSections(_ updateInfo: UpdateInfo) {
        let containUpdateInfoSection: Bool = sections.first(where: { $0.type == .updateFailureInfo }) is UpdateInfoPTViewModel
        switch (updateInfo.areProductsUpdated, containUpdateInfoSection) {
            
        case (true, true):
            sections.removeFirst()
        case (false, false):
            sections.insert(UpdateInfoPTViewModel.init(), at: 0)
        default:
            break
        }
    }
    
    private func showProductProfile(
        _ productID: ProductData.ID
    ) {
        guard let product = model.product(productId: productID),
              let productProfileViewModel = paymentsTransfersFactory.makeProductProfileViewModel(
                product,
                "\(type(of: self))",
                { [weak self] in self?.event(.dismiss(.destination)) })
        else { return }
        
        productProfileViewModel.rootActions = rootActions
        bind(productProfileViewModel)
        route.destination = .productProfile(productProfileViewModel)
    }
    
    private func showOpenDeposit() {
        
        let openDepositViewModel = OpenDepositListViewModel(
            model,
            catalogType: .deposit,
            dismissAction: { [weak self] in
                
                self?.event(.dismiss(.destination))
            }
        )
        route.destination = .openDepositsList(openDepositViewModel)
    }
    
    private func handleUserAccountButtonTapped() {
        
        guard let clientInfo = model.clientInfo.value
        else {return }
        
        model.action.send(ModelAction.C2B.GetC2BSubscription.Request())
        // TODO: replace with factory
        route.destination = .userAccount(.init(
            navigationStateManager: userAccountNavigationStateManager,
            model: model,
            clientInfo: clientInfo,
            dismissAction: { [weak self] in self?.event(.dismiss(.destination)) }
        ))
    }
    
    private func showRequisites(qrCode: QRCode) {
        
        self.event(.dismiss(.modal))
        let paymentsViewModel = PaymentsViewModel(
            source: .requisites(qrCode: qrCode),
            model: model,
            closeAction: { [weak self] in
                
                self?.event(.dismiss(.destination))
            }
        )
        bind(paymentsViewModel)
        
        self.action.send(DelayWrappedAction(
            delayMS: 700,
            action: PaymentsTransfersViewModelAction.Show.Payment(viewModel: paymentsViewModel)))
    }
    
    func handlePaymentButtonTapped(_ action: any Action) {
        
        if !model.updateInfo.value.areCardsOrAccountsUpdated, let alertViewModel = paymentsTransfersFactory.makeAlertDataUpdateFailureViewModel({ self.action.send(ProductProfileViewModelAction.Close.Alert()) }) {
            event(.setModal(to: .alert(alertViewModel)))
        } else {
            
            switch action {
                //LatestPayments Section Buttons
            case let payload as LatestPaymentsViewModelAction.ButtonTapped.LatestPayment:
                switch payload.latestPayment.type {
                case .service:
                    event(.paymentTrigger(.latestPayment(payload.latestPayment)))
                
                default:
                    handle(latestPayment: payload.latestPayment)
                }
                
                //LatestPayment Section TemplateButton
            case _ as LatestPaymentsViewModelAction.ButtonTapped.Templates:
                handleTemplatesButtonTapped()
                
            case _ as LatestPaymentsViewModelAction.ButtonTapped.CurrencyWallet:
                handleCurrencyWalletButtonTapped()
                
                //Transfers Section
            case let payload as PTSectionTransfersViewAction.ButtonTapped.Transfer:
                handleTransferButtonTapped(for: payload.type)
                
                //Payments Section
            case let payload as PTSectionPaymentsViewAction.ButtonTapped.Payment:
                handlePaymentButtonTapped(for: payload.type)
                
            default:
                break
            }
        }
    }
    
    private func bindSections(
        _ sections: [PaymentsTransfersSectionViewModel]
    ) {
        for section in sections {
            
            section.action
                .receive(on: scheduler)
                .sink { [weak self] in self?.handlePaymentButtonTapped($0) }
                .store(in: &bindings)
        }
    }
    
    private func handleTemplatesButtonTapped() {
        
        let viewModel = paymentsTransfersFactory.makeTemplatesListViewModel { [weak self] in
            
            self?.event(.dismiss(.destination))
        }
        
        bind(viewModel)
        route.destination = .template(viewModel)
    }
    
    private func handleCurrencyWalletButtonTapped() {
        
        guard let firstCurrencyWalletData = model.currencyWalletList.value.first
        else { return }
        
        let currency = Currency(description: firstCurrencyWalletData.code)
        
        guard let walletViewModel = CurrencyWalletViewModel(
            currency: currency,
            currencyOperation: .buy,
            model: model,
            dismissAction: { [weak self] in self?.event(.dismiss(.destination)) })
        else { return }
        
        model.action.send(ModelAction.Dictionary.UpdateCache.List(types: [.currencyWalletList, .currencyList, .countriesWithService]))
        
        route.destination = .currencyWallet(walletViewModel)
    }
    
    private func handleTransferButtonTapped(
        for type: PTSectionTransfersView.ViewModel.TransfersButtonType
    ) {
        switch type {
        case .abroad:
            self.action.send(PaymentsTransfersViewModelAction.Show.Countries())
            
        case .anotherCard:
            handleAnotherCardTransferButtonTapped()
            
        case .betweenSelf:
            handleBetweenSelfTransferButtonTapped()
            
        case .requisites:
            payByRequisites()
            
        case .byPhoneNumber:
            self.action.send(PaymentsTransfersViewModelAction.Show.Contacts())
        }
    }
    
    private func handleAnotherCardTransferButtonTapped() {
        
        model.action.send(ModelAction.ProductTemplate.List.Request())
        let paymentsViewModel = PaymentsViewModel(
            model,
            service: .toAnotherCard,
            closeAction: { [weak self] in self?.event(.dismiss(.destination)) }
        )
        bind(paymentsViewModel)
        
        self.action.send(PaymentsTransfersViewModelAction.Show.Payment(viewModel: paymentsViewModel))
    }
    
    private func handleBetweenSelfTransferButtonTapped() {
        
        guard let viewModel = PaymentsMeToMeViewModel(model, mode: .demandDeposit)
        else { return }
        
        bind(viewModel)
        
        route.modal = .bottomSheet(.init(type: .meToMe(viewModel)))
    }
    
    private func handlePaymentButtonTapped(
        for type: PTSectionPaymentsView.ViewModel.PaymentsType
    ) {
        switch type {
        case .mobile:
            handleMobilePaymentButtonTapped()
            
        case .qrPayment:
            // на экране платежей нижний переход
            self.openScanner()
            
        case .service, .internet:
            makeUtilitiesViewModel(for: type)
            
        case .transport:
            bindTransport()
            
        case .taxAndStateService:
            let paymentsViewModel = PaymentsViewModel(
                category: Payments.Category.taxes,
                model: model
            ) { [weak self] in
                
                self?.event(.dismiss(.destination))
            }
            route.destination = .payments(paymentsViewModel)
            
        case .socialAndGame:
            route.modal = .bottomSheet(.init(type: .exampleDetail(type.rawValue))) //TODO:
            
        case .security:
            route.modal = .bottomSheet(.init(type: .exampleDetail(type.rawValue)))
            //TODO:
            
        case .others:
            route.modal = .bottomSheet(.init(type: .exampleDetail(type.rawValue))) //TODO:
        }
    }
    
    private func handleMobilePaymentButtonTapped() {
        
        let paymentsViewModel = PaymentsViewModel(
            model,
            service: .mobileConnection,
            closeAction: { [weak self] in self?.event(.dismiss(.destination)) }
        )
        bind(paymentsViewModel)
        
        self.action.send(PaymentsTransfersViewModelAction.Show.Payment(viewModel: paymentsViewModel))
    }
    
    private func makeByInstructionsPaymentsViewModel() -> PaymentsViewModel {
        
        let paymentsViewModel = PaymentsViewModel(
            model,
            service: .requisites,
            closeAction: { [weak self] in self?.event(.dismiss(.destination)) }
        )
        bind(paymentsViewModel)
        
        return paymentsViewModel
    }
    
    private func payByRequisites() {
        
        action.send(PaymentsTransfersViewModelAction.Show.Payment(
            viewModel: makeByInstructionsPaymentsViewModel()
        ))
    }
    
    private func makeUtilitiesPayload(
        forType type: PTSectionPaymentsView.ViewModel.PaymentsType
    ) -> PaymentsTransfersFactory.MakeUtilitiesPayload {
        
        return .init(
            type: type,
            navLeadingAction: { [weak self] in self?.event(.dismiss(.destination)) },
            navTrailingAction: { [weak self] in
                self?.event(.dismiss(.destination))
                self?.action.send(PaymentsTransfersViewModelAction.ButtonTapped.Scanner())
            },
            addCompany: { [weak self] in self?.event(.outside(.addCompany)) },
            requisites: { [weak self] in
                
                self?.event(.dismiss(.destination))
                self?.action.send(PaymentsTransfersViewModelAction.Show.Requisites(qrCode: .init(original: "", rawData: [:])))
            }
        )
    }
    
    private func makeUtilitiesPayload(
        forType type: PTSectionPaymentsView.ViewModel.PaymentsType
    ) -> Event.PaymentButton.LegacyPaymentPayload {
        
        return .init(
            type: type,
            navLeadingAction: { [weak self] in self?.event(.dismiss(.destination)) },
            navTrailingAction: { [weak self] in
                self?.event(.dismiss(.destination))
                self?.action.send(PaymentsTransfersViewModelAction.ButtonTapped.Scanner())
            },
            addCompany: { [weak self] in self?.event(.outside(.addCompany)) },
            requisites: { [weak self] in
                
                self?.event(.dismiss(.destination))
                self?.action.send(PaymentsTransfersViewModelAction.Show.Requisites(qrCode: .init(original: "", rawData: [:])))
            }
        )
    }
    
    private func bindTransport() {
        
        let transportPaymentsViewModel = model.makeTransportPaymentsViewModel(
            type: .transport,
            handleError: { [weak self] in
                
                self?.action.send(PaymentsTransfersViewModelAction.Show.Alert(title: "Ошибка", message: $0))
            }
        )
        
        if let transportPaymentsViewModel {
            
            self.route.destination = .transportPayments(transportPaymentsViewModel)
            
        } else {
            
            self.action.send(PaymentsTransfersViewModelAction.Show.Alert(title: "Ошибка", message: "Ошибка создания транспортных платежей"))
        }
    }
    
    private func bind(_ templatesListViewModel: TemplatesListViewModel) {
        
        templatesListViewModel.action
            .receive(on: scheduler)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as TemplatesListViewModelAction.OpenProductProfile:
                    
                    self.event(.dismiss(.destination))
                    self.delay(for: .milliseconds(800)) {
                        
                        self.action.send(
                            PaymentsTransfersViewModelAction.Show.ProductProfile(
                                productId: payload.productId
                            )
                        )
                    }
                    
                default:
                    break
                }
            }
            .store(in: &bindings)
    }
    
    private func bind(_ productProfile: ProductProfileViewModel) {
        
        productProfile.action
            .compactMap { $0 as? ProductProfileViewModelAction.MyProductsTapped.OpenDeposit }
            .receive(on: scheduler)
            .sink { [unowned self] _ in
                
                self.event(.dismiss(.destination))
                self.delay(for: .milliseconds(800)) {
                    
                    self.action.send(PaymentsTransfersViewModelAction.Show.OpenDeposit())
                }
            }
            .store(in: &bindings)
    }
    
    private func bind(_ paymentsViewModel: PaymentsViewModel) {
        
        paymentsViewModel.action
            .receive(on: scheduler)
            .sink { [unowned self] action in
                
                switch action {
                case _ as PaymentsViewModelAction.ScanQrCode:
                    self.event(.dismiss(.destination))
                    self.delay(for: .milliseconds(800)) {
                        self.openScanner()
                    }
                    
                case let payload as PaymentsViewModelAction.ContactAbroad:
                    handleContactAbroad(source: payload.source)
                    
                default: break
                }
            }
            .store(in: &bindings)
    }
    
    private func handleContactAbroad(
        source: Payments.Operation.Source
    ) {
        let paymentsViewModel = PaymentsViewModel(
            source: source,
            model: model
        ) { [weak self] in
            
            self?.event(.dismiss(.destination))
        }
        
        self.action.send(DelayWrappedAction(
            delayMS: 700,
            action: PaymentsTransfersViewModelAction.Show.Payment(viewModel: paymentsViewModel))
        )
    }
    
    private func bind(_ viewModel: PaymentsMeToMeViewModel) {
        
        viewModel.action
            .receive(on: scheduler)
            .sink { [unowned self, weak viewModel] action in
                
                switch action {
                case let payload as PaymentsMeToMeAction.Response.Success:
                    handleSuccessResponseMeToMe(
                        meToMeViewModel: viewModel,
                        successViewModel: payload.viewModel
                    )
                    
                case _ as PaymentsMeToMeAction.Response.Failed:
                    
                    makeAlert("Перевод выполнен")
                    self.event(.dismiss(.modal))
                    
                case _ as PaymentsMeToMeAction.Close.BottomSheet:
                    
                    self.event(.dismiss(.modal))
                    
                case let payload as PaymentsMeToMeAction.InteractionEnabled:
                    
                    guard case let .bottomSheet(bottomSheet) = route.modal
                    else { return }
                    
                    bottomSheet.isUserInteractionEnabled.value = payload.isUserInteractionEnabled
                    
                default:
                    break
                }
            }
            .store(in: &bindings)
    }
    
    func handleSuccessResponseMeToMe(
        meToMeViewModel: PaymentsMeToMeViewModel?,
        successViewModel: PaymentsSuccessViewModel
    ) {

        bind(successViewModel)
        fullCover = .init(type: .successMeToMe(successViewModel))
    }
    
    private func bind(_ viewModel: PaymentsSuccessViewModel) {
        
        viewModel.action
            .receive(on: scheduler)
            .sink { [unowned self] action in
                
                switch action {
                case _ as PaymentsSuccessAction.Button.Close:
                    closeSuccess()
                    
                case _ as PaymentsSuccessAction.Button.Repeat:
                    repeatSuccess()
                    
                default:
                    break
                }
            }
            .store(in: &bindings)
    }
    
    private func closeSuccess() {
                
        self.action.send(PaymentsTransfersViewModelAction.Close.FullCover())
        self.action.send(PaymentsTransfersViewModelAction.Close.DismissAll())
        self.rootActions?.switchTab(.main)
    }
    
    private func repeatSuccess() {
        
        self.action.send(PaymentsTransfersViewModelAction.Close.FullCover())
        self.rootActions?.switchTab(.payments)
    }
    
    private func bind(_ viewModel: ContactsViewModel) {
        
        viewModel.action
            .receive(on: scheduler)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as ContactsViewModelAction.PaymentRequested:
                    requestContactsPayment(source: payload.source)
                    
                case let payload as ContactsSectionViewModelAction.Countries.ItemDidTapped:
                    handleCountriesItemTapped(source: payload.source)
                    
                default:
                    break
                }
            }
            .store(in: &bindings)
    }
    
    private func requestContactsPayment(
        source: Payments.Operation.Source
    ) {
        self.event(.dismiss(.modal))
        
        switch source {
        case let .latestPayment(latestPaymentId):
            guard let latestPayment = model.latestPayments.value.first(where: { $0.id == latestPaymentId })
            else { return }
            
            handle(latestPayment: latestPayment)
            
        default:
            let paymentsViewModel = PaymentsViewModel(
                source: source,
                model: model
            ) { [weak self] in
                
                guard let self else { return }
                
                self.event(.dismiss(.destination))
                
                switch source {
                case .direct:
                    self.action.send(DelayWrappedAction(
                        delayMS: 300,
                        action: PaymentsTransfersViewModelAction.Show.Countries())
                    )
                    
                case .sfp:
                    self.action.send(DelayWrappedAction(
                        delayMS: 300,
                        action: PaymentsTransfersViewModelAction.Show.Contacts())
                    )
                    
                default: break
                }
            }
            
            bind(paymentsViewModel)
            
            self.action.send(DelayWrappedAction(
                delayMS: 300,
                action: PaymentsTransfersViewModelAction.Show.Payment(viewModel: paymentsViewModel))
            )
        }
    }
    
    private func handleCountriesItemTapped(
        source: Payments.Operation.Source
    ) {
        let paymentsViewModel = PaymentsViewModel(
            source: source,
            model: model
        ) { [weak self] in
            
            guard let self else { return }
            
            self.event(.dismiss(.destination))
            
            switch source {
            case .direct:
                self.action.send(DelayWrappedAction(
                    delayMS: 300,
                    action: PaymentsTransfersViewModelAction.Show.Countries())
                )
                
            case .sfp:
                self.action.send(DelayWrappedAction(
                    delayMS: 300,
                    action: PaymentsTransfersViewModelAction.Show.Contacts())
                )
                
            default: break
            }
        }
        
        bind(paymentsViewModel)
        self.action.send(DelayWrappedAction(
            delayMS: 300,
            action: PaymentsTransfersViewModelAction.Show.Payment(viewModel: paymentsViewModel))
        )
    }
    
    func bind(_ qrModel: QRModel) -> AnyCancellable {
        
        qrModel.$state
            .compactMap { $0 }
            .debounce(for: 0.1, scheduler: DispatchQueue.main)
            .receive(on: scheduler)
            .sink { [weak self] in
                
                switch $0 {
                case .cancelled:
                    self?.rootActions?.spinner.hide()
                    self?.action.send(MainViewModelAction.Close.FullScreenSheet())
                    
                case .inflight:
                    self?.rootActions?.spinner.show()
                    
                case let .qrResult(qrResult):
                    self?.rootActions?.spinner.hide()
                    self?.handleQRResult(qrResult)
                }
            }
    }
    
    private func payByInstructions() {
        
        event(.dismiss(.destination))
        event(.dismiss(.modal))
        
        let paymentsViewModel = makeByInstructionsPaymentsViewModel()
        
        action.send(DelayWrappedAction(
            delayMS: 800,
            action: PaymentsTransfersViewModelAction.Show.Payment(viewModel: paymentsViewModel))
        )
    }
    
    private func payByInstructions(with qrCode: QRCode) {
        
        event(.dismiss(.destination))
        event(.dismiss(.modal))

        action.send(PaymentsTransfersViewModelAction.Show.Requisites(qrCode: qrCode))
    }
    
    private func makeAlert(_ message: String) {
        
        let alertViewModel = Alert.ViewModel(title: "Ошибка", message: message, primary: .init(type: .default, title: "ОК") { [weak self] in
            self?.action.send(ProductProfileViewModelAction.Close.Alert())
        })
        
        route.modal = .alert(alertViewModel)
    }
    
    private func createNavButtonsRight(
    ) -> [NavigationBarButtonViewModel] {
        
        [.barcodeScanner(action: { [weak self] in self?.openScanner() })]
    }
}

// MARK: - Helpers

extension PaymentsTransfersViewModel {
    
    private func handleQRResult(
        _ result: QRViewModel.ScanResult
    ) {
        event(.dismiss(.modal))

        switch result {
        case let .qrCode(qr):
            
            if let qrMapping = model.qrMapping.value {
                handleQRMapping(qr, qrMapping)
            } else {
                handleFailure(qr: qr)
            }
            
        case let .c2bURL(url):
            handleC2bURL(url)
            
        case let .c2bSubscribeURL(url):
            handleC2bSubscribeURL(url)
            
        case let .sberQR(url):
            handleSberQRURL(url)
            
        case let .url(url):
            handleURL(url)

        case .unknown:
            handleUnknownQR()
        }
    }
    
    private func handleQRMapping(
        _ qr: QRCode,
        _ qrMapping: QRMapping
    ) {
        let operators = model.operatorsFromQR(qr, qrMapping)
        let multipleOperators = MultiElementArray(operators ?? [])
        
        switch (multipleOperators, operators?.first) {
        case let (_, .some(`operator`)):
            payWith(operator: `operator`, qr: qr, qrMapping: qrMapping)
            
        case let (.some(multipleOperators), _):
            scheduler.delay(for:.milliseconds(700)) { [weak self] in
                
                self?.handleQRMappingWithMultipleOperators(qr, multipleOperators.elements)
            }
            
        default:
            self.action.send(PaymentsTransfersViewModelAction.Show.Requisites(qrCode: qr))
        }
    }
    
    private func payWith(
        operator: OperatorGroupData.OperatorData,
        qr: QRCode,
        qrMapping: QRMapping
    ) {
        let isServicePayment = Payments
            .paymentsServicesOperators
            .map(\.rawValue)
            .contains(`operator`.parentCode)
        
        if isServicePayment {
            handleQRMappingWithSingleOperator(qr, `operator`)
        } else {
            delay(for: .milliseconds(700)) { [self] in
                
                let viewModel = InternetTVDetailsViewModel(
                    model: model,
                    qrCode: qr,
                    mapping: qrMapping
                )
                self.route.destination = .operatorView(viewModel)
            }
        }
    }
    
    private func handleQRMappingWithSingleOperator(
        _ qr: QRCode,
        _ operatorValue: OperatorGroupData.OperatorData
    ) {
        let puref = operatorValue.code
        let additionalList = model.additionalList(for: operatorValue, qrCode: qr)
        let amount: Double = qr.rawData["sum"]?.toDouble() ?? 0
        let paymentsViewModel = PaymentsViewModel(
            source: .servicePayment(
                puref: puref,
                additionalList: additionalList,
                amount: amount/100
            ),
            model: model,
            closeAction: { [weak self] in
                
                self?.model.action.send(PaymentsTransfersViewModelAction.Close.Link())
            }
        )
        bind(paymentsViewModel)
        
        scheduler.schedule { [weak self] in
            
            self?.route.destination = .init(.payments(paymentsViewModel))
        }
    }
    
    private func handleQRMappingWithMultipleOperators(
        _ qr: QRCode,
        _ operators: [OperatorGroupData.OperatorData]
    ) {
        let navigationBarViewModel = NavigationBarView.ViewModel(
            title: "Все регионы",
            titleButton: .init(
                icon: Image.ic24ChevronDown,
                action: { [weak self] in
                    
                    self?.model.action.send(QRSearchOperatorViewModelAction.OpenCityView())
                }
            ),
            leftItems: [
                NavigationBarView.ViewModel.BackButtonItemViewModel(
                    icon: .ic24ChevronLeft,
                    action: { [weak self] in self?.event(.dismiss(.destination)) })
            ]
        )
        
        let operatorsViewModel = QRSearchOperatorViewModel(
            searchBar: .nameOrTaxCode(),
            navigationBar: navigationBarViewModel, model: self.model,
            operators: operators,
            addCompanyAction: { [weak self] in self?.event(.outside(.addCompany)) },
            requisitesAction: { [weak self] in self?.payByInstructions(with: qr) },
            qrCode: qr
        )
        
        route.destination = .searchOperators(operatorsViewModel)
    }
    
    private func handleUnknownQR() {
        
        delay(for: .milliseconds(700)) {
            
            let failedView = QRFailedViewModel(
                model: self.model,
                addCompanyAction: { [weak self] in self?.event(.outside(.addCompany)) },
                requisitsAction: { [weak self] in self?.payByInstructions() }
            )
            self.route.destination = .failedView(failedView)
        }
    }

    private func handleFailure(qr: QRCode) {
        
        delay(for: .milliseconds(700)) { [weak self] in
            
            guard let self else { return }
            
            let failedView = QRFailedViewModel(
                model: self.model,
                addCompanyAction: { [weak self] in self?.event(.outside(.addCompany)) },
                requisitsAction: { [weak self] in self?.payByInstructions(with: qr) }
            )
            
            route.destination = .failedView(failedView)
        }
    }
    
    private func handleC2bURL(_ url: URL) {
        
        let paymentsViewModel = PaymentsViewModel(
            source: .c2b(url),
            model: model,
            closeAction: { [weak self] in self?.event(.dismiss(.destination)) }
        )
        bind(paymentsViewModel)
        
        action.send(DelayWrappedAction(
            delayMS: 700,
            action: PaymentsTransfersViewModelAction.Show.Payment(viewModel: paymentsViewModel))
        )
    }
    
    private func handleC2bSubscribeURL(_ url: URL) {
        
        let paymentsViewModel = PaymentsViewModel(
            source: .c2bSubscribe(url),
            model: model,
            closeAction: { [weak self] in self?.event(.dismiss(.destination)) }
        )
        bind(paymentsViewModel)
        
        self.action.send(DelayWrappedAction(
            delayMS: 700,
            action: PaymentsTransfersViewModelAction.Show.Payment(viewModel: paymentsViewModel))
        )
    }
    
    private func handleSberQRURL(_ url: URL) {
        
        rootActions?.spinner.show()
        
        sberQRServices.getSberQRData(url) { [weak self] result in
            
            DispatchQueue.main.async { [weak self] in
                
                self?.handleGetSberQRDataResult(url, result)
            }
        }
    }
    
    private func handleGetSberQRDataResult(
        _ url: URL,
        _ result: SberQRServices.GetSberQRDataResult
    ) {
        rootActions?.spinner.hide()
        
        switch result {
        case .failure:
            self.route.modal = .alert(.techError { [weak self] in self?.event(.dismiss(.modal)) })
            
        case let .success(getSberQRDataResponse):
            do {
                let viewModel = try qrViewModelFactory.makeSberQRConfirmPaymentViewModel(
                    getSberQRDataResponse,
                    { [weak self] in self?.sberQRPay(url: url, state: $0) }
                )
                self.route.destination = .sberQRPayment(viewModel)
                
            } catch {
                
                self.route.modal = .alert(.techError { [weak self] in self?.event(.dismiss(.modal)) })
            }
        }
    }
    
    private func sberQRPay(
        url: URL,
        state: SberQRConfirmPaymentState
    ) {
        // action.send(MainViewModelAction.Close.Link())
        rootActions?.spinner.show()
        
        // TODO: move conversion to factory
        guard let payload = state.makePayload(with: url)
        else { return }
        
        sberQRServices.createSberQRPayment(payload) { [weak self] result in
            
            DispatchQueue.main.async { [weak self] in
                
                self?.handleCreateSberQRPaymentResult(result)
            }
        }
    }
    
    private func handleCreateSberQRPaymentResult(
        _ result: CreateSberQRPaymentResult
    ) {
        rootActions?.spinner.hide()
        event(.dismiss(.destination))
        
        delay(for: .milliseconds(400)) { [weak self] in
            
            guard let self else { return }
            
            switch result {
            case .failure:
                self.route.modal = .alert(.techError { [weak self] in self?.event(.dismiss(.modal)) })
                
            case let .success(success):
                let successViewModel = qrViewModelFactory.makePaymentsSuccessViewModel(success)
                self.route.modal = .fullScreenSheet(.init(type: .success(successViewModel)))
            }
        }
    }
    
    private func handleURL(
        _ url: URL
    ) {
        delay(for: .milliseconds(700)) {
            
            let failedView = QRFailedViewModel(
                model: self.model,
                addCompanyAction: { [weak self] in self?.event(.outside(.addCompany)) },
                requisitsAction: { [weak self] in self?.payByInstructions() }
            )
            
            self.route.destination = .failedView(failedView)
        }
    }
}

private extension NavigationBarButtonViewModel {
    
    static func barcodeScanner(
        action: @escaping () -> Void
    ) -> Self {
        
        return .init(
            icon: .ic24BarcodeScanner2,
            action: action
        )
    }
}
