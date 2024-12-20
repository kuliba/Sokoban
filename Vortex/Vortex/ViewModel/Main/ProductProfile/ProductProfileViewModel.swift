//
//  ProductProfileViewModel.swift
//  Vortex
//
//  Created by Дмитрий on 09.03.2022.
//

import ActivateSlider
import CardUI
import Combine
import VortexTools
import Foundation
import OperatorsListComponents
import PDFKit
import PinCodeUI
import SwiftUI
import Tagged
import RxViewModel
import LandingUIComponent
import UIPrimitives
import ManageSubscriptionsUI
import CalendarUI

class ProductProfileViewModel: ObservableObject {
    
    typealias CardAction = CardDomain.CardAction
    typealias ResultShowCVV = Swift.Result<CardInfo.CVV, Error>
    typealias CompletionShowCVV = (ResultShowCVV) -> Void
    typealias ShowCVV = (CardDomain.CardId, @escaping CompletionShowCVV) -> Void

    let action: PassthroughSubject<Action, Never> = .init()
    
    let navigationBar: NavigationBarView.ViewModel
    @Published var product: ProductProfileCardView.ViewModel
    @Published var buttons: ProductProfileButtonsView.ViewModel
    @Published var detail: ProductProfileDetailView.ViewModel?
    @Published var history: ProductProfileHistoryView.ViewModel?
    @Published var payment: PaymentsViewModel?
    @Published var operationDetail: OperationDetailViewModel?
    @Published var accentColor: Color
    
    @Published var historyState: HistoryState?
    @Published var filterState: FilterState

    let filterHistoryRequest: (Date, Date, String?, [String]) -> Void
    
    @Published var bottomSheet: BottomSheet?
    @Published var link: Link? { didSet { isLinkActive = link != nil } }
    @Published var isLinkActive: Bool = false
    @Published var sheet: Sheet?
    @Published var alert: Alert.ViewModel?
    @Published var textFieldAlert: AlertTextFieldView.ViewModel?
    @Published var spinner: SpinnerView.ViewModel?
    @Published var fullScreenCoverState: FullScreenCoverState?
    @Published var success: PaymentsSuccessViewModel?
    
    @Published var closeAccountSpinner: CloseAccountSpinnerView.ViewModel?
    
    var controlPanelViewModel: ControlPanelViewModel?
    var rootActions: RootViewModel.RootActions?
    var rootView: String
    var contactsAction: () -> Void = { }
    var navigationTitleForControlPanel: String { productData?.navigationTitleForControlPanel ?? ""}
    
    var historyPool: [ProductData.ID : ProductProfileHistoryView.ViewModel]
    let model: Model
    let makeOpenNewProductButtons: OpenNewProductsViewModel.MakeNewProductButtons
    private let fastPaymentsFactory: FastPaymentsFactory
    private let makePaymentsTransfersFlowManager: MakePTFlowManger
    private let userAccountNavigationStateManager: UserAccountNavigationStateManager
    private let sberQRServices: SberQRServices
    public let productProfileServices: ProductProfileServices
    private let qrViewModelFactory: QRViewModelFactory
    private let paymentsTransfersFactory: PaymentsTransfersFactory
    private let operationDetailFactory: OperationDetailFactory
    private let cvvPINServicesClient: CVVPINServicesClient
    private var cardAction: CardAction?
    private let productProfileViewModelFactory: ProductProfileViewModelFactory
    
    private let productNavigationStateManager: ProductProfileFlowManager

    private var bindings = Set<AnyCancellable>()
    
    private var productData: ProductData? {
        model.products.value.values.flatMap({ $0 }).first(where: { $0.id == self.product.activeProductId })
    }
        
    private let depositResponseSubject = CurrentValueSubject<Bool, Never>(false)
    private let bottomSheetSubject = PassthroughSubject<BottomSheet?, Never>()
    private let alertSubject = PassthroughSubject<Alert.ViewModel?, Never>()
    private let historySubject = PassthroughSubject<HistoryState?, Never>()
    private let filterSubject = PassthroughSubject<FilterState, Never>()
    private let paymentSubject = PassthroughSubject<PaymentsViewModel?, Never>()

    init(
        navigationBar: NavigationBarView.ViewModel,
        product: ProductProfileCardView.ViewModel,
        buttons: ProductProfileButtonsView.ViewModel,
        detail: ProductProfileDetailView.ViewModel?,
        history: ProductProfileHistoryView.ViewModel?,
        operationDetail: OperationDetailViewModel? = nil,
        accentColor: Color = .purple,
        historyPool: [ProductData.ID : ProductProfileHistoryView.ViewModel] = [:],
        model: Model = .emptyMock,
        fastPaymentsFactory: FastPaymentsFactory,
        makePaymentsTransfersFlowManager: @escaping MakePTFlowManger,
        userAccountNavigationStateManager: UserAccountNavigationStateManager,
        sberQRServices: SberQRServices,
        productProfileServices: ProductProfileServices,
        qrViewModelFactory: QRViewModelFactory,
        paymentsTransfersFactory: PaymentsTransfersFactory,
        operationDetailFactory: OperationDetailFactory,
        productNavigationStateManager: ProductProfileFlowManager,
        cvvPINServicesClient: CVVPINServicesClient,
        filterHistoryRequest: @escaping (Date, Date, String?, [String]) -> Void,
        makeOpenNewProductButtons: @escaping OpenNewProductsViewModel.MakeNewProductButtons,
        productProfileViewModelFactory: ProductProfileViewModelFactory,
        filterState: FilterState,
        rootView: String,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.navigationBar = navigationBar
        self.product = product
        self.buttons = buttons
        self.detail = detail
        self.history = history
        self.operationDetail = operationDetail
        self.accentColor = accentColor
        self.historyPool = historyPool
        self.model = model
        self.fastPaymentsFactory = fastPaymentsFactory
        self.makePaymentsTransfersFlowManager = makePaymentsTransfersFlowManager
        self.userAccountNavigationStateManager = userAccountNavigationStateManager
        self.sberQRServices = sberQRServices
        self.productProfileServices = productProfileServices
        self.qrViewModelFactory = qrViewModelFactory
        self.paymentsTransfersFactory = paymentsTransfersFactory
        self.operationDetailFactory = operationDetailFactory
        self.cvvPINServicesClient = cvvPINServicesClient
        self.filterHistoryRequest = filterHistoryRequest
        self.rootView = rootView
        self.productNavigationStateManager = productNavigationStateManager
        self.productProfileViewModelFactory = productProfileViewModelFactory
        self.filterState = filterState
        self.makeOpenNewProductButtons = makeOpenNewProductButtons
        self.cardAction = createCardAction(cvvPINServicesClient, model)
        
        // TODO: add removeDuplicates
        self.bottomSheetSubject
            //.removeDuplicates()
            .receive(on: scheduler)
            .assign(to: &$bottomSheet)
        
        self.alertSubject
            //.removeDuplicates()
            .receive(on: scheduler)
            .assign(to: &$alert)
        
        self.historySubject
            //.removeDuplicates()
            .receive(on: scheduler)
            .assign(to: &$historyState)

        self.filterSubject
            //.removeDuplicates()
            .receive(on: scheduler)
            .assign(to: &$filterState)
        
        self.paymentSubject
            //.removeDuplicates()
            .receive(on: scheduler)
            .assign(to: &$payment)

        LoggerAgent.shared.log(level: .debug, category: .ui, message: "ProductProfileViewModel initialized")
    }
    
    deinit {
        
        LoggerAgent.shared.log(level: .debug, category: .ui, message: "ProductProfileViewModel deinitialized")
    }
    
    convenience init?(
        _ model: Model,
        fastPaymentsFactory: FastPaymentsFactory,
        makePaymentsTransfersFlowManager: @escaping MakePTFlowManger,
        userAccountNavigationStateManager: UserAccountNavigationStateManager,
        sberQRServices: SberQRServices,
        productProfileServices: ProductProfileServices,
        qrViewModelFactory: QRViewModelFactory,
        paymentsTransfersFactory: PaymentsTransfersFactory,
        operationDetailFactory: OperationDetailFactory,
        cvvPINServicesClient: CVVPINServicesClient,
        product: ProductData,
        productNavigationStateManager: ProductProfileFlowManager,
        productProfileViewModelFactory: ProductProfileViewModelFactory,
        filterHistoryRequest: @escaping (Date, Date, String?, [String]) -> Void,
        filterState: FilterState,
        rootView: String,
        dismissAction: @escaping () -> Void,
        makeOpenNewProductButtons: @escaping OpenNewProductsViewModel.MakeNewProductButtons,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        guard let productViewModel = ProductProfileCardView.ViewModel(
            model,
            productData: product,
            cardAction: { _ in },
            showCvv: nil)
        else { return nil }
        
        // status bar
        let navigationBar = NavigationBarView.ViewModel(product: product, dismissAction: dismissAction)
        let buttons = ProductProfileButtonsView.ViewModel(with: product, depositInfo: model.depositsInfo.value[product.id])
        let accentColor = Self.accentColor(with: product)
        
        self.init(
            navigationBar: navigationBar,
            product: productViewModel,
            buttons: buttons,
            detail: nil,
            history: nil,
            accentColor: accentColor,
            model: model,
            fastPaymentsFactory: fastPaymentsFactory,
            makePaymentsTransfersFlowManager: makePaymentsTransfersFlowManager,
            userAccountNavigationStateManager: userAccountNavigationStateManager,
            sberQRServices: sberQRServices,
            productProfileServices: productProfileServices,
            qrViewModelFactory: qrViewModelFactory,
            paymentsTransfersFactory: paymentsTransfersFactory,
            operationDetailFactory: operationDetailFactory,
            productNavigationStateManager: productNavigationStateManager,
            cvvPINServicesClient: cvvPINServicesClient,
            filterHistoryRequest: filterHistoryRequest,
            makeOpenNewProductButtons: makeOpenNewProductButtons,
            productProfileViewModelFactory: productProfileViewModelFactory,
            filterState: filterState,
            rootView: rootView,
            scheduler: scheduler
        )
        
        self.product = ProductProfileCardView.ViewModel(
            model,
            productData: product,
            cardAction: self.cardAction,
            showCvv: { [weak self] cardId, completion in
                
                guard let self else { return }
                
                self.showCvvByTap(
                    cardId: cardId,
                    completion: completion)
            },
            event: { [weak self] event in
                    
                guard let self else { return }
                
                switch event {
                case let .delayAlert(kind):
                    self.event(.alert(.delayAlert(kind)))
                 
                case let .delayAlertViewModel(alertViewModel):
                    self.event(.alert(.delayAlertViewModel(alertViewModel)))
                    
                case .closeAlert:
                    self.event(.alert(.closeAlert))
                    
                case let .showAlert(alert):
                    self.event(.alert(.showAlert(alert)))
                }
            }
        )!
        
        // detail view model
        self.detail = makeDetailViewModel(with: product)
        
        // history view model
        let historyViewModel = makeHistoryViewModel(productType: product.productType, productId: product.id, model: model)
        self.history = historyViewModel
        self.historyPool[product.id] = historyViewModel
        
        bind(product: self.product)
        bind(history: historyViewModel)
        bind(detail: detail)
        bind(buttons: buttons)
        
        bind()
    }
}

extension ProductProfileViewModel {
    
    func closeLinkAndResendRequest(
        cardId: CardDomain.CardId,
        actionType: ConfirmViewModel.CVVPinAction
    ) {
        switch actionType {
            
        case .restartChangePin:
            guard let productCard = model.product(productId: cardId.rawValue)?.asCard else { return }
            checkCertificate(.init(cardId.rawValue), certificate: self.cvvPINServicesClient, productCard)
            
        case let .changePin(displayNumber):
            action.send(DelayWrappedAction(
                delayMS: 200,
                action: ProductProfileViewModelAction.CVVPin.ChangePin(
                    cardId: cardId,
                    phone: displayNumber)
            ))
            
        case .showCvv:
            DispatchQueue.main.async { [weak self] in
                
                self?.showCVV(cardId: cardId)
            }
            
        case let .changePinResult(result):
            switch result {
            case .successScreen:
                successScreenForChangePin()
            case .errorScreen:
                errorScreenForChangePin()
            }
        }
    }
    
    func showCVV(
        cardId: CardDomain.CardId
    ) {
        showCvvByTap(
            cardId: cardId
        ) { [weak self] cvv in
            
            guard let self else { return }
            
            if let cvv {
                let delayedShowCVVAction = DelayWrappedAction(
                    delayMS: 200,
                    action: ProductProfileCardView.ViewModel.CVVPinViewModelAction.ShowCVV(cardId: cardId, cvv: cvv)
                )
                product.action.send(delayedShowCVVAction)
                
                if case let .productInfo(productInfoViewModel) = link {
                    
                    productInfoViewModel.action.send(InfoProductModelAction.ShowCVV(cardId: cardId, cvv: cvv))
                }
            }
        }
    }
    
    func confirmShowCVV(
        withOTP otp: OtpDomain.Otp,
        completion: @escaping (ErrorDomain?) -> Void
    ) {
        cvvPINServicesClient.confirmWith(otp: otp.rawValue) { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case .success:
                model.action.send(ModelAction.Informer.Show(informer: .init(message: "Сертификат Активирован", icon: .check)))
                completion(nil)
                
            case let .failure(error):
                completion(CVVPinErrorMapper.map(error))
            }
        }
    }
    
    func pinConfirmation(
        completion: @escaping (PinCodeViewModel.PhoneNumberState) -> Void
    ) {
        cvvPINServicesClient.getPINConfirmationCode { [weak self] result in
            
            guard self != nil else { return }
            
            switch result {
            case let .success(phone):
                completion(.phone(.init(value: phone)))
                
            case let .failure(error):
                //self.makeAlert(error.localizedDescription)
                completion(.error(error))
            }
        }
    }
    
    func confirmChangePin(
        info: ConfirmViewModel.ChangePinStruct,
        completion: @escaping (ErrorDomain?) -> Void
    ) {
        cvvPINServicesClient.changePin(
            cardId: info.cardId.rawValue,
            newPin: info.newPin.rawValue,
            otp: info.otp.rawValue
        ) { [weak self] result in
            
            guard self != nil else { return }
            
            switch result {
            case .success:
                completion(nil)
                
            case let .failure(error):
                completion(CVVPinErrorMapper.map(error))
            }
        }
    }
    
    func createCardAction(
        _ cvvPINServicesClient: CVVPINServicesClient,
        _ model: Model
    ) -> CardAction? {
        
        return {
            switch $0 {
            case let .copyCardNumber(message):
                model.action.send(ModelAction.Informer.Show(
                    informer: .init(
                        message: message,
                        icon: .copy,
                        type: .copyInfo
                    )
                ))
            }
        }
    }
}

// MARK: - Bindings

private extension ProductProfileViewModel {
    
    func bind() {
                
        action
            .compactMap { $0 as? DelayWrappedAction }
            .flatMap {
                
                Just($0.action)
                    .delay(for: .milliseconds($0.delayMS), scheduler: DispatchQueue.main)
                
            }
            .sink { [weak self] in
                
                self?.action.send($0)
            }
            .store(in: &bindings)
        
        action
            .compactMap { $0 as? ProductProfileViewModelAction.CVVPin.ChangePin }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] payload in
                
                guard let self else { return }

                self.fullScreenCoverState = .changePin(.init(
                    cardId: payload.cardId,
                    displayNumber: payload.phone,
                    model: self.createPinCodeViewModel(displayNumber: payload.phone), 
                    request: self.resendOtpForPin
                ))
            }
            .store(in: &bindings)
        
        // TransferButtonDidTapped
        
        action
            .compactMap { $0 as? ProductProfileViewModelAction.TransferButtonDidTapped }
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                
                model.setPreferredProductID(to: product.activeProductId)
                
                let paymentsTransfersViewModel = PaymentsTransfersViewModel(
                    model: model,
                    makeFlowManager: makePaymentsTransfersFlowManager,
                    userAccountNavigationStateManager: userAccountNavigationStateManager,
                    sberQRServices: sberQRServices,
                    qrViewModelFactory: qrViewModelFactory,
                    paymentsTransfersFactory: paymentsTransfersFactory,
                    isTabBarHidden: true,
                    mode: .link
                )
                paymentsTransfersViewModel.rootActions = rootActions
                link = .paymentsTransfers(.init(model: paymentsTransfersViewModel, cancellables: []))
                
            }.store(in: &bindings)
        
        action
            .compactMap { $0 as? ProductProfileViewModelAction.DepositTransferButtonDidTapped }
            .flatMap { [unowned self] _ in
                self.depositResponseSubject
                    .filter { $0 }
                    .first()
            }
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                
                self.handleDepositTransfer()
            }.store(in: &bindings)
        
        // Confirm OTP
        
        action
            .compactMap { $0 as? ProductProfileViewModelAction.CVVPin.ConfirmShow }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] action in
                
                self?.alert = nil
                self?.fullScreenCoverState = .confirmOTP(.init(
                    cardId: action.cardId,
                    action: action.actionType,
                    phone: action.phone,
                    request: action.resendOtp
                ))
            }
            .store(in: &bindings)
        
        // Show Spinner
        action
            .compactMap { $0 as? ProductProfileViewModelAction.Spinner.Show }
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
//                withAnimation {
                    self.spinner = .init()
//                }
            }.store(in: &bindings)
        
        // Hide Spinner
        action
            .compactMap { $0 as? ProductProfileViewModelAction.Spinner.Hide }
            .receive(on: DispatchQueue.main)
            .sink { [unowned self]  _ in
//                withAnimation {
                    self.spinner = nil
//                }
            }.store(in: &bindings)
        
        $isLinkActive
            .sink { [unowned self] value in
                
                if value == false {
                    
                    model.setPreferredProductID(to: nil)
                }
                
            }.store(in: &bindings)
        
        $filterState
            .sink { state in

                if let lowerDate = state.calendar.range?.lowerDate,
                   let upperDate = state.calendar.range?.upperDate {
                    
                    self.history?.action.send(ProductProfileHistoryViewModelAction.Filter(
                        filterState: state,
                        period: (
                            lowerDate,
                            upperDate
                        ))
                    )
                }
                
                if let period = state.filter.selectDates {
                
                    let lowerDate = period.lowerBound
                    let upperDate = period.upperBound
                    self.history?.action.send(ProductProfileHistoryViewModelAction.Filter(
                        filterState: state, 
                        period: (
                            lowerDate,
                            upperDate
                        ))
                    )
                }
                
            }.store(in: &bindings)
        
        action
            .compactMap { $0 as? ProductProfileViewModelAction.PullToRefresh }
            .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                
                if let productType = productData?.productType {
                    model.action.send(ModelAction.Products.Update.ForProductType(productType: productType))
                }
               
                model.action.send(ModelAction.Statement.List.Request(
                    productId: product.activeProductId,
                    direction: .latest,
                    operationType: nil,
                    category: nil
                ))
                
                switch product.productType {
                case .deposit:
                    model.action.send(ModelAction.Deposits.Info.Single.Request(productId: product.activeProductId))
                case .loan:
                    model.action.send(ModelAction.Loans.Update.Single.Request(productId: product.activeProductId))
                default:
                    break
                }
            }
            .store(in: &bindings)
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                switch action {
                    
                case let payload as ProductProfileViewModelAction.Show.OptionsPannel:
                    bind(optionsPannel: payload.viewModel)
                    bottomSheet = .init(type: .optionsPannel(payload.viewModel))
                    
                case let payload as ProductProfileViewModelAction.Show.AlertShow:
                    self.alert = payload.viewModel
                    
                case _ as ProductProfileViewModelAction.Product.Activate:
                    alert = .init(title: "Активировать карту?", message: "После активации карта будет готова к использованию", primary: .init(type: .default, title: "Отмена", action: { [weak self] in
                        self?.alert = nil
                    }), secondary: .init(type: .default, title: "Ok", action: { [weak self] in
                        //TODO: implemetation required
                        self?.alert = nil
                    }))
                    
                case _ as ProductProfileViewModelAction.Product.Block:
                    
                    blockCard(with: productData)
                case _ as ProductProfileViewModelAction.Product.Unblock:
                    
                    unblockCard(with: productData)
                    
                case _ as ProductProfileViewModelAction.Show.PlacesMap:
                    guard let placesViewModel = PlacesViewModel(model) else {
                        return
                    }
                    sheet = .init(type: .placesMap(placesViewModel))
                    
                case let payload as ProductProfileViewModelAction.Product.UpdateCustomName:
                    textFieldAlert = customNameAlert(for: payload.productType, alertTitle: payload.alertTitle)
                    
                case let payload as ProductProfileViewModelAction.Product.CloseAccount:
                    
                    let from = payload.productFrom
                    let balance = payload.productFrom.balanceValue
                    
                    if balance == 0 {
                        
                        closeAccountSpinner = .init(model, productData: from)
                        
                        if let closeAccountSpinner = closeAccountSpinner {
                            bind(closeAccountSpinner)
                        }
                        
                        if let productFrom = from.asAccount {
                            
                            model.action.send(ModelAction.Account.Close.Request(payload: .init(id: from.id, name: productFrom.name, startDate: nil, endDate: nil, statementFormat: nil, accountId: nil, cardId: nil)))
                        }
                        
                    } else {
                        
                        guard let viewModel = PaymentsMeToMeViewModel(model, mode: .closeAccount(from, balance)) else {
                            return
                        }
                        
                        bind(viewModel)
                        bottomSheet = .init(type: .meToMe(viewModel))
                    }
                    
                case _ as ProductProfileViewModelAction.Close.Link:
                    link = nil
                    
                case _ as ProductProfileViewModelAction.Close.Sheet:
                    sheet = nil
                    
                case _ as ProductProfileViewModelAction.Close.Success:
                    fullScreenCoverState = nil
                    success = nil
                    
                case _ as ProductProfileViewModelAction.Close.AccountSpinner:
                    closeAccountSpinner = nil
                    
                case _ as ProductProfileViewModelAction.Close.BottomSheet:
                    bottomSheet = nil
                    
                case _ as PaymentsTransfersViewModelAction.Close.DismissAll:
                    
//                    withAnimation {
                        NotificationCenter.default.post(name: .dismissAllViewAndSwitchToMainTab, object: nil)
//                    }
                    
                case _ as ProductProfileViewModelAction.Close.Alert:
                    alert = nil
                    
                case _ as ProductProfileViewModelAction.Close.TextFieldAlert:
                    textFieldAlert = nil
                    
                case _ as ProductProfileViewModelAction.Show.MeToMeExternal:
                    if let productData = productData as? ProductLoanData, let loanAccount = self.model.products.value[.account]?.first(where: {$0.number == productData.settlementAccount}) {
                        
                        let meToMeExternalViewModel = MeToMeExternalViewModel(
                            productTo: loanAccount,
                            closeAction: { [weak self] in self?.action.send(ProductProfileViewModelAction.Close.Link())},
                            getUImage: { self.model.images.value[$0]?.uiImage }
                        )
                        self.link = .meToMeExternal(meToMeExternalViewModel)
                    } else {
                        
                        let meToMeExternalViewModel = MeToMeExternalViewModel(
                            productTo: productData,
                            closeAction: { [weak self] in
                                self?.action.send(ProductProfileViewModelAction.Close.Link())
                            },
                            getUImage: { self.model.images.value[$0]?.uiImage }
                        )
                        self.link = .meToMeExternal(meToMeExternalViewModel)
                    }
                default:
                    break
                }
            }.store(in: &bindings)
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                 
                case let payload as ModelAction.C2B.CancelC2BSub.Response:
                    let paymentSuccessViewModel = PaymentsSuccessViewModel(paymentSuccess: .init(with: payload.data), model)
                    if let controlPanelViewModel {
                        
                        controlPanelViewModel.event(.destination(
                            .successView(paymentSuccessViewModel)
                        ))
                    }
                    
                case let payload as ModelAction.C2B.GetC2BDetail.Response:
                    
                    if let controlPanelViewModel {
                        
                        controlPanelViewModel.event(.destination(
                            .successView(.init(
                                paymentSuccess: .init(
                                    operation: nil,
                                    parameters: payload.params),
                                model
                            ))
                        ))
                    }
                    
                case let payload as ModelAction.Products.UpdateCustomName.Response:
                    
                    switch payload {
                    case .complete(productId: let productId, name: let name):
                        guard let product = model.products.value.values.flatMap({ $0 }).first(where: { $0.id == productId }) else {
                            return
                        }
                        
//                        withAnimation {
                            
                            navigationBar.updateName(with: name)
                            accentColor = Self.accentColor(with: product)
//                        }
                        
                    case .failed(message: let message):
                        alert = .init(title: "Ошибка", message: message, primary: .init(type: .default, title: "Ok", action: { [weak self] in
                            self?.alert = nil
                        }))
                    }
                
                case let payload as ModelAction.Card.Unblock.Response:
                    hideSpinner()

                case let payload as ModelAction.Card.Block.Response:
                    hideSpinner()
                    switch payload.result {
                    case .success:
                        model.handleProductUpdateDynamicParamsList(payload.cardId, productType: .card)
                        model.action.send(ModelAction.Products.Update.ForProductType(productType: .card))
                        
                    case .failure(let errorMessage):
                        alert = .init(title: "Ошибка", message: errorMessage, primary: .init(type: .default, title: "Ok", action: { [weak self] in
                            self?.alert = nil
                        }))
                    }
                    
                case let payload as ModelAction.Products.DepositConditionsPrintForm.Response:
                    switch payload.result {
                    case .success(let data):
                        if let document = PDFDocument(data: data) {
                            
                            let printFormViewModel = PrintFormView.ViewModel(pdfDocument: document)
                            self.sheet = .init(type: .printForm(printFormViewModel))
                            
                        } else {
                            
                            self.alert = errorDepositConditionAlert(data: data)
                            
                        }
                        
                    case .failure(let error):
                        let alertViewModel = Alert.ViewModel(title: "Ошибка",
                                                             message: error.localizedDescription,
                                                             primary: .init(type: .default, title: "Наши офисы", action: { [weak self] in
                            self?.action.send(ProductProfileViewModelAction.Close.Alert())
                            self?.action.send(ProductProfileViewModelAction.Show.PlacesMap())}),
                                                             secondary: .init(type: .default, title: "ОК", action: { [weak self] in
                            self?.action.send(ProductProfileViewModelAction.Close.Alert())
                        }))
                        self.alert = .init(alertViewModel)
                    }
                    
                case let payload as ModelAction.Deposits.Info.Single.Response:
                    
                    hideSpinner()
                    
                    switch payload {
                    case .success(data: _):
                        
                        guard let productData else { return }
                        depositResponseSubject.send(true)
                        buttons.update(with: productData, depositInfo: model.depositsInfo.value[productData.id])
                        
                    default:
                        break
                    }
                    
                case let payload as ModelAction.Settings.ApplicationSettings.Response:
                    
                    switch payload.result {
                        
                    case .success(let settings):
                        if settings.allowCloseDeposit, let product = productData as? ProductDepositData, let openDate = product.openDate, let number = product.number {
                            
                            if product.isDemandDeposit {
                                let displayNumber = product.displayNumber ?? number
                                let topString = "Вы действительно хотите закрыть вклад №*\(displayNumber)?\n\n"
                                let alertViewModel = Alert.ViewModel(title: "Закрыть вклад",
                                                                     message: "\(topString)При закрытии будет предложено перевести остаток денежных средств на другой счет/карту. Вклад будет закрыт после совершения перевода.",
                                                                     primary: .init(type: .default, title: "Отмена", action: { [weak self] in self?.action.send(ProductProfileViewModelAction.Close.Alert())}),
                                                                     secondary: .init(type: .default, title: "Закрыть", action: { [weak self] in
                                    guard let self = self,
                                          let depositProduct = self.model.product(productId: self.product.activeProductId) as? ProductDepositData else {
                                        return
                                    }
                                    
                                    guard let viewModel = PaymentsMeToMeViewModel(self.model, mode: .transferAndCloseDeposit(depositProduct, depositProduct.balanceValue)) else {
                                        return
                                    }
                                    
                                    self.bind(viewModel)
                                    
                                    self.bottomSheet = .init(type: .meToMe(viewModel))
                                }))
                                self.alert = .init(alertViewModel)
                            }
                            else{
                                
                                let dateFormatter = DateFormatter.historyFullDateFormatter
                                let bottomString = "Подробнее в договоре \"Условия срочного банковского вклада \n№\(number)\nот \(dateFormatter.string(from: openDate))\""
                                let alertViewModel = Alert.ViewModel(title: "Закрыть вклад",
                                                                     message: "Срок вашего вклада еще не истек.\n\nПри досрочном закрытии вклада возможна потеря или перерасчет начисленных процентов.\n\n\(bottomString)",
                                                                     primary: .init(type: .default, title: "Отмена", action: { [weak self] in self?.action.send(ProductProfileViewModelAction.Close.Alert())}),
                                                                     secondary: .init(type: .default, title: "Продолжить", action: { [weak self] in
                                    if let id = self?.product.activeProductId {
                                        
                                        self?.model.action.send(ModelAction.Deposits.BeforeClosing.Request(depositId: id, operDate: Date()))
                                        self?.spinner = .init()
                                    }
                                }))
                                self.alert = .init(alertViewModel)
                            }
                        } else {
                            
                            let alertViewModel = Alert.ViewModel(title: "Закрыть вклад",
                                                                 message: "Срок вашего вклада еще не истек. Для досрочного закрытия обратитесь в ближайший офис",
                                                                 primary: .init(type: .default, title: "Наши офисы", action: { [weak self] in self?.action.send(ProductProfileViewModelAction.Show.PlacesMap())}),
                                                                 secondary: .init(type: .default, title: "ОК", action: { [weak self] in self?.action.send(ProductProfileViewModelAction.Close.Alert())}))
                            self.alert = .init(alertViewModel)
                        }
                        
                    case .failure(let error):
                        let alertViewModel = Alert.ViewModel(title: "Ошибка",
                                                             message: error.localizedDescription,
                                                             primary: .init(type: .default, title: "Наши офисы", action: { [weak self] in self?.action.send(ProductProfileViewModelAction.Show.PlacesMap())}),
                                                             secondary: .init(type: .default, title: "ОК", action: { [weak self] in self?.action.send(ProductProfileViewModelAction.Close.Alert())}))
                        self.alert = .init(alertViewModel)
                        
                    }
                    
                case let payload as ModelAction.Deposits.BeforeClosing.Response:
                    self.spinner = nil
                    
                    switch payload {
                    case .success(data: let amount):
                        guard let depositProduct = self.model.product(productId: self.product.activeProductId) as? ProductDepositData else {
                            return
                        }
                        
                        guard let viewModel = PaymentsMeToMeViewModel(model, mode: .closeDeposit(depositProduct, amount)) else {
                            return
                        }
                        
                        bind(viewModel)
                        bottomSheet = .init(type: .meToMe(viewModel))
                        
                    case .failure(message: let errorMessage):
                        self.alert = .init(title: "Ошибка", message: errorMessage, primary: .init(type: .default, title: "Ок", action: {}))
                        
                    }
                    
                default: break
                }
                
            }.store(in: &bindings)
        
        model.products
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] product in
                
                guard let productData = productData else {
                    return
                }
                
//                withAnimation {
                    buttons.update(with: productData, depositInfo: model.depositsInfo.value[productData.id])
                    
                    if let card = productData.asCard {
                        
                        let newButtons = productProfileViewModelFactory.makeCardGuardianPanel(card).controlPanelButtons
                        controlPanelViewModel?.event(.updateState(newButtons))
                    }
//                }
                
            }.store(in: &bindings)
        
        model.loans
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] loans in
                
                guard product.productType == .loan else {
                    return
                }
                
                if let productLoan = model.products.value[.loan]?.first(where: { $0.id == product.activeProductId }) as? ProductLoanData,
                   let loanData = loans.first(where: { $0.loandId == product.activeProductId}) {
                    
//                    withAnimation {
                        
                        if let detail = detail {
                            
                            detail.update(productLoan: productLoan, loanData: loanData, model: model)
                            
                        } else {
                            
                            detail = .init(productLoan: productLoan, loanData: loanData, model: model)
                            bind(detail: detail)
                        }
//                    }
                    
                } else {
                    
//                    withAnimation {
                        detail = nil
//                    }
                }
                
            }.store(in: &bindings)
        
        product.$activeProductId
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] activeProductId in
                
                guard let product = model.products.value.values.flatMap({ $0 }).first(where: { $0.id == activeProductId }) else {
                    return
                }
                self.product.productType = product.productType
                
                if let deposit = self.model.products.value.values.flatMap({ $0 }).first(where: { $0.id == self.product.activeProductId }) as? ProductDepositData {
                    
                    self.model.action.send(ModelAction.Deposits.Info.Single.Request(productId: deposit.id))
                    depositResponseSubject.send(false)
                }
                // status bar update
//                withAnimation {
                    
                    navigationBar.update(with: product)
                    accentColor = Self.accentColor(with: product)
//                }
                
                // buttons update
//                withAnimation {
                    buttons.update(with: product, depositInfo: model.depositsInfo.value[product.id])
//                }
                
                // detail update
//                withAnimation {
                    detail = makeDetailViewModel(with: product)
//                }
                
                bind(detail: detail)
                
                // history update
                if let historyViewModel = historyPool[activeProductId] {
                    
//                    withAnimation {
                        history = historyViewModel
//                    }
                    self.event(.history(.clearOptions))
                    
                } else {
                    
                    let historyViewModel = makeHistoryViewModel(productType: product.productType, productId: activeProductId, model: model)
                    
//                    withAnimation {
                        history = historyViewModel
//                    }
                    
                    self.event(.history(.clearOptions))
                    
                    historyPool[activeProductId] = historyViewModel
                    bind(history: historyViewModel)
                }
                
                if product.productType == .card || product.productType == .account {
                    
                    guard let alertTitle = alertTitle(for: product.productType) else { return }
                    
//                    withAnimation {
                        
                        navigationBar.rightItems = [ NavigationBarView.ViewModel.ButtonItemViewModel(icon: .ic16Edit2, action: { [weak self] in
                            
                            self?.action.send(ProductProfileViewModelAction.Product.UpdateCustomName(productId: product.id, productType: product.productType, alertTitle: alertTitle))
                        })]
//                    }
                } else {
                    
//                    withAnimation {
                        
                        navigationBar.rightItems = []
//                    }
                }
                
            }.store(in: &bindings)
    }
    
    func bind(product: ProductProfileCardView.ViewModel) {
        
        product.action
            .compactMap({ $0 as? DelayWrappedAction })
            .receive(on: DispatchQueue.main)
            .flatMap({
                
                Just($0.action)
                    .delay(for: .milliseconds($0.delayMS), scheduler: DispatchQueue.main)
                
            })
            .sink(receiveValue: { [weak product] in
                
                product?.action.send($0)
                
            }).store(in: &bindings)
        
        product.action
            .receive(on: DispatchQueue.main)
            .sink { [weak self] productAction in
                
                guard let self else { return }
                
                switch productAction {
                case _ as ProductProfileCardViewModelAction.MoreButtonTapped:
                    
                    if rootView == "\(MyProductsViewModel.self)" {
                        
                        action.send(ProductProfileViewModelAction.Close.SelfView())
                    } else {
                        let myProductsViewModel = MyProductsViewModel(
                            model,
                            cardAction: cardAction,
                            makeProductProfileViewModel: makeProductProfileViewModel,
                            openOrderSticker: {}, 
                            makeMyProductsViewFactory: .init(
                                makeInformerDataUpdateFailure: productProfileViewModelFactory.makeInformerDataUpdateFailure
                            ),
                            makeOpenNewProductButtons: makeOpenNewProductButtons
                        )
                        myProductsViewModel.rootActions = rootActions
                        link = .myProducts(myProductsViewModel)
                    }
                    
                case let payload as ProductProfileCardViewModelAction.ShowAlert:
                    alert = Alert.ViewModel(
                        title: payload.title,
                        message: payload.message,
                        primary: .init(
                            type: .default,
                            title: "Ок",
                            action: {}
                        )
                    )
                    
                default:
                    break
                }
            }
            .store(in: &bindings)
    }
    
    func bind(history: ProductProfileHistoryView.ViewModel?) {
        
        guard let history = history else { return }
        
        history.action
            .receive(on: DispatchQueue.main)
            .sink { [weak self] action in
                
                guard let self = self else { return }
                
                switch action {
                case let payload as ProductProfileHistoryViewModelAction.DidTapped.Detail:
                    
                    guard let storage = self.model.statements.value[self.product.activeProductId],
                          let latestStatementData = storage.statements
                        .filter({ $0.operationId == payload.statementId })
                        .sorted(by: { ($0.tranDate ?? $0.date) > ($1.tranDate ?? $1.date) })
                        .first,
                          latestStatementData.paymentDetailType != .notFinance,
                          let productData = self.model.products.value.values
                        .flatMap({ $0 })
                        .first(where: { $0.id == self.product.activeProductId }) 
                    else { return }
                    
                    let operationDetailViewModel = operationDetailFactory.makeOperationDetailViewModel(
                        latestStatementData,
                        productData,
                        self.model
                    )
                    self.bottomSheet = .init(type: .operationDetail(operationDetailViewModel))
                    
                    if #unavailable(iOS 14.5) {
                        self.bind(operationDetailViewModel)
                    }
                    
                default:
                    break
                }
            }.store(in: &bindings)
    }
    
    func bind(detail: ProductProfileDetailView.ViewModel?) {
        
        detail?.action
            .receive(on: DispatchQueue.main)
            .sink{[unowned self] action in
                
                switch action {
                case let payload as ProductProfileDetailViewModelAction.MakePayment:
                    
                    guard let product = model.product(productId: payload.settlementAccountId),
                          let meToMeViewModel = PaymentsMeToMeViewModel(model, mode: .makePaymentTo(product, payload.amount)) else {
                        return
                    }
                    
                    bind(meToMeViewModel)
                    bottomSheet = .init(type: .meToMe(meToMeViewModel))
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
    }
    
    func bind(_ operationDetailViewModel: OperationDetailViewModel) {
        
        operationDetailViewModel.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as OperationDetailViewModelAction.ShowInfo:
                    self.action.send(ProductProfileViewModelAction.Close.BottomSheet())
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(700)) {
                        
                        self.bottomSheet = .init(type: .info(payload.viewModel))
                    }
                    
                case let payload as OperationDetailViewModelAction.ShowDocument:
                    self.action.send(ProductProfileViewModelAction.Close.BottomSheet())
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(700)) {
                        
                        self.bottomSheet = .init(type: .printForm(payload.viewModel))
                    }
                    
                case _ as OperationDetailViewModelAction.CloseSheet:
                    bottomSheet = nil
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
    }
    
    func bind(buttons: ProductProfileButtonsView.ViewModel) {
        
        buttons.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as ProductProfileButtonsSectionViewAction.ButtonDidTapped:
                    
                    switch payload.buttonType {
                    case .topLeft:
                        let allowCreditValue = self.productData?.allowCredit == false
                        let productType = self.productData?.productType.order == 2
                        
                        if !(allowCreditValue && productType ) {
                            
                            if let card = productData?.asCard {
                                topLeftActionForCard(card)
                            }
                            else  {
                                let optionsPannelViewModel = ProductProfileOptionsPannelView.ViewModel(title: "Пополнить", buttonsTypes: [.refillFromOtherBank, .refillFromOtherProduct], productType: product.productType)
                                self.action.send(ProductProfileViewModelAction.Show.OptionsPannel(viewModel: optionsPannelViewModel))
                            }
                            
                        } else {
                            
                            let alertView = Alert.ViewModel(
                                title: "Невозможно пополнить",
                                message: "Вклад не предусматривает возможности пополнения.\nПодробнее в информации по вкладу в деталях",
                                primary: .init(type: .default, title: "ОК", action: { [weak self] in self?.action.send(ProductProfileViewModelAction.Close.Alert())})
                            )
                            
                            self.alert = .init(alertView)
                        }
                        
                    case .topRight:
                        switch product.productType {
                        case .card:
                            topRightActionForCard(productData)
                            
                        case .account:
                            self.action.send(ProductProfileViewModelAction.TransferButtonDidTapped())
                            
                        case .deposit:
                            
                            if !self.depositResponseSubject.value {
                                self.showSpinner()
                            }
                            self.action.send(ProductProfileViewModelAction.DepositTransferButtonDidTapped())
                            
                        default:
                            break
                        }
                        
                    case .bottomLeft:
                        switch product.productType {
                            
                        case .card:
                            guard let card = productData?.asCard else { return }
                            createAccountInfoPanel(card)

                        case .deposit:
                            let optionsPannelViewModel = ProductProfileOptionsPannelView.ViewModel(buttonsTypes: [.requisites, .statement, .info, .contract], productType: product.productType)
                            self.action.send(ProductProfileViewModelAction.Show.OptionsPannel(viewModel: optionsPannelViewModel))
                            
                        case .account:
                            let optionsPannelViewModel = ProductProfileOptionsPannelView.ViewModel(buttonsTypes: [.requisites, .statement, .statementOpenAccount(false), .tariffsByAccount, .termsOfService], productType: product.productType)
                            self.action.send(ProductProfileViewModelAction.Show.OptionsPannel(viewModel: optionsPannelViewModel))
                            
                        default:
                            let optionsPannelViewModel = ProductProfileOptionsPannelView.ViewModel(buttonsTypes: [.requisites, .statement], productType: product.productType)
                            self.action.send(ProductProfileViewModelAction.Show.OptionsPannel(viewModel: optionsPannelViewModel))
                            
                        }
                        
                    case .bottomRight:
                        
                        switch product.productType {
                        case .card:
                            createCardGuardianPanel(productData)
                            
                        case .account:
                            
                            guard let productFrom = productData,
                                  let accountNumber = productFrom.accountNumber else {
                                return
                            }
                            
                            let lastAccountNumber = "*\(accountNumber.suffix(4))"
                            let title = "Закрыть счет"
                            
                            var message = "Вы действительно хотите закрыть счет \(lastAccountNumber)?"
                            
                            if productFrom.balanceValue > 0 {
                                
                                message = "\(message)\n\nПри закрытии будет предложено перевести остаток денежных средств на другой счет/карту. Счет будет закрыт после совершения перевода."
                            }
                            
                            alert = .init(
                                title: title,
                                message: message,
                                primary: .init(type: .default, title: "Отмена") { [weak self] in
                                    
                                    guard let self = self else { return }
                                    self.alert = nil
                                },
                                secondary: .init(type: .default, title: "Продолжить") { [weak self] in
                                    
                                    guard let self = self else { return }
                                    self.action.send(ProductProfileViewModelAction.Product.CloseAccount(productFrom: productFrom))
                                })
                            
                        case .deposit:
                            
                            if let deposit = productData as? ProductDepositData {
                                
                                let optionsPannelViewModel = ProductProfileOptionsPannelView.ViewModel(buttonsTypes: [.closeDeposit(deposit.isCanClosedDeposit)], productType: product.productType)
                                self.action.send(ProductProfileViewModelAction.Show.OptionsPannel(viewModel: optionsPannelViewModel))
                            }
                            
                        case .loan:
                            let optionsPannelViewModel = ProductProfileOptionsPannelView.ViewModel(buttonsTypes: [.refillFromOtherBank, .refillFromOtherProduct], productType: product.productType)
                            self.action.send(ProductProfileViewModelAction.Show.OptionsPannel(viewModel: optionsPannelViewModel))
                        }
                    }
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
    }
    
    private func handleDepositTransfer() {
        
        guard let depositProduct = self.model.products.value.values.flatMap({ $0 }).first(where: { $0.id == self.product.activeProductId }) as? ProductDepositData,
              let depositInfo = model.depositsInfo.value[self.product.activeProductId],
              let transferType = depositProduct.availableTransferType(with: depositInfo) else {
            return
        }

        switch transferType {
        case .remains:
            guard let viewModel = PaymentsMeToMeViewModel(self.model, mode: .transferDeposit(depositProduct, 0)) else {
                return
            }
            self.bind(viewModel)
            self.bottomSheet = .init(type: .meToMe(viewModel))

        case let .interest(amount):
            let meToMeViewModel = MeToMeViewModel(type: .transferDepositInterest(depositProduct, amount), closeAction: {})
            self.bottomSheet = .init(type: .meToMeLegacy(meToMeViewModel))

        case let .close(amount):
            let meToMeViewModel = MeToMeViewModel(type: .transferBeforeCloseDeposit(depositProduct, amount), closeAction: {})
            self.bottomSheet = .init(type: .meToMeLegacy(meToMeViewModel))
        }
    }
    
    func bind(product: InfoProductViewModel) {
        
        product.action
            .compactMap({ $0 as? DelayWrappedAction })
            .flatMap({
                
                Just($0.action)
                    .delay(for: .milliseconds($0.delayMS), scheduler: DispatchQueue.main)
                
            })
            .sink(receiveValue: { [weak product] in
                
                product?.action.send($0)
                
            }).store(in: &bindings)
        
        product.action
            .compactMap({ $0 as? InfoProductModelAction.ShowCVV })
            .receive(on: DispatchQueue.main)
            .sink { [weak product] payload in
                
                guard let product else { return }
                
                let cardId: Int = payload.cardId.rawValue
                
                if product.product.id == cardId {
                    product.additionalList = product.updateAdditionalList(
                        oldList: product.additionalList,
                        newCvv: payload.cvv.rawValue
                    )
                }
            }.store(in: &bindings)
        
        product.action
            .compactMap({ $0 as? InfoProductModelAction.Spinner.Show })
            .receive(on: DispatchQueue.main)
            .sink { [weak product] _ in
                
                guard let product else { return }
                
//                withAnimation {
                    product.spinner = .init()
//                }
            }.store(in: &bindings)
        
        product.action
            .compactMap({ $0 as? InfoProductModelAction.Spinner.Hide })
            .receive(on: DispatchQueue.main)
            .sink { [weak product] _ in
                
                guard let product else { return }
                
//                withAnimation {
                    product.spinner = nil
//                }
            }.store(in: &bindings)
        
        product.action
            .compactMap({ $0 as? InfoProductModelAction.Close })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.action.send(ProductProfileViewModelAction.Close.Link())
            }
            .store(in: &bindings)
    }
    
    func bind(optionsPannel: ProductProfileOptionsPannelView.ViewModel) {
        
        optionsPannel.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                self.action.send(ProductProfileViewModelAction.Close.BottomSheet())
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) { [weak self] in
                    
                    guard let self, let productData = self.productData else {
                        return
                    }
                    
                    switch action {
                    case let payload as ProductProfileOptionsPannelViewModelAction.ButtonTapped:
                        switch payload.buttonType {
                        case .requisites:
                            let productInfoViewModel = productProfileViewModelFactory.makeInfoProductViewModel(
                                .init(
                                    model: model,
                                    productData: productData,
                                    info: false,
                                    showCVV: { [weak self] cardId, completion in
                                        
                                        guard let self else { return }
                                        
                                        self.showCvvByTap(
                                            cardId: cardId,
                                            completion: completion)
                                    },
                                    events: { event in self.event(.alert(event)) }
                                )
                            )
                            
                            self.link = .productInfo(productInfoViewModel)
                            self.bind(product: productInfoViewModel)
                            
                        case .info:
                            let productInfoViewModel = productProfileViewModelFactory.makeInfoProductViewModel(
                                .init(
                                    model: model,
                                    productData: productData,
                                    info: true)
                            )

                            self.link = .productInfo(productInfoViewModel)
                            
                        case .statement:
                            let productStatementViewModel = ProductStatementViewModel(
                                product: productData,
                                closeAction: { [weak self] in self?.action.send(ProductProfileViewModelAction.Close.Link())},
                                getUImage: { self.model.images.value[$0]?.uiImage }
                            )
                            self.link = .productStatement(productStatementViewModel)
                            
                        case .refillFromOtherProduct:
                            if let productData = productData as? ProductLoanData,
                               let loanAccount = self.model.products.value[.account]?
                                .first(where: {$0.number == productData.settlementAccount}) {
                                
                                guard let viewModel = PaymentsMeToMeViewModel(
                                    self.model,
                                    mode: .makePaymentTo(loanAccount, 0.0))
                                else { return }
                                
                                self.bind(viewModel)
                                self.bottomSheet = .init(type: .meToMe(viewModel))
                                
                            } else if let productData = productData as? ProductDepositData,
                                      productData.isDemandDeposit { //только вклады
                                
                                guard let viewModel = PaymentsMeToMeViewModel(self.model, mode: .makePaymentToDeposite(productData, 0)) else {
                                    return
                                }
                                
                                self.bind(viewModel)
                                
                                self.bottomSheet = .init(type: .meToMe(viewModel))
                            }
                            else {
                                
                                guard let viewModel = PaymentsMeToMeViewModel(
                                    self.model,
                                    mode: .makePaymentTo(productData, 0.0))
                                else { return }
                                
                                self.bind(viewModel)
                                self.bottomSheet = .init(type: .meToMe(viewModel))
                            }
                            
                        case .refillFromOtherBank:
                            self.action.send(ProductProfileViewModelAction.Show.MeToMeExternal())
                            
                        case .conditions:
                            self.model.action.send(ModelAction.Products.DepositConditionsPrintForm.Request(depositId: productData.id))
                            
                        case .contract:
                            
                            let printFormViewModel = PrintFormView.ViewModel(type: .contract(productId: productData.id), model: self.model, dismissAction: { [weak self]  in
                                
                                self?.action.send(ProductProfileViewModelAction.Close.BottomSheet())
                                self?.action.send(ProductProfileViewModelAction.Close.Sheet())
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000)) {
                                    
                                    let alertViewModel = Alert.ViewModel(title: "Форма временно недоступна",
                                                                         message: "Для получения Договора по вкладу обратитесь в отделение банка",
                                                                         primary: .init(type: .default, title: "Наши офисы", action: { [weak self] in self?.action.send(ProductProfileViewModelAction.Show.PlacesMap())}),
                                                                         secondary: .init(type: .default, title: "ОК", action: { [weak self] in self?.action.send(ProductProfileViewModelAction.Close.Alert())}))
                                    
                                    self?.action.send(ProductProfileViewModelAction.Show.AlertShow(viewModel: alertViewModel))
                                }
                            })
                            
                            self.sheet = .init(type: .printForm(printFormViewModel))
                            
                        case .closeDeposit:
                            
                            guard let product = productData as? ProductDepositData else {
                                return
                            }
                            
                            self.action.send(ProductProfileViewModelAction.Close.BottomSheet())
                            self.action.send(ProductProfileViewModelAction.Close.Sheet())
                            
                            if product.isDemandDeposit {
                                
                                self.model.action.send(ModelAction.Settings.ApplicationSettings.Request())
                                
                            } else {
                                
                                switch product.depositType {
                                case .birjevoy:
                                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000)) {
                                        
                                        let alertViewModel = Alert.ViewModel(title: "Закрыть вклад",
                                                                             message: "Операции по вкладу «Биржевой» вы можете осуществить в вашем личном кабинете на финансовой платформе «Финуслуги» ПАО «Московская Биржа ММВБ-РТС»",
                                                                             primary: .init(type: .default, title: "Отмена", action: {}),
                                                                             secondary: .init(type: .default, title: "Перейти", action: { [weak self] in self?.action.send(ProductProfileViewModelAction.Close.Alert())
                                            
                                            if let depositCloseBirjevoyURL = self?.model.depositCloseBirjevoyURL {
                                                
                                                self?.openLinkURL(depositCloseBirjevoyURL)
                                            }
                                        }))
                                        
                                        self.action.send(ProductProfileViewModelAction.Show.AlertShow(viewModel: alertViewModel))
                                    }
                                case .multi:
                                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000)) {
                                        
                                        let alertViewModel = Alert.ViewModel(title: "Закрыть вклад",
                                                                             message: "Срок вашего вклада еще не истек. Для досрочного закрытия обратитесь в ближайший офис",
                                                                             primary: .init(type: .default, title: "Наши офисы", action: { [weak self] in
                                            self?.action.send(ProductProfileViewModelAction.Close.Alert())
                                            self?.action.send(ProductProfileViewModelAction.Show.PlacesMap())
                                        }),
                                                                             secondary: .init(type: .default, title: "Ок", action: {}))
                                        
                                        self.action.send(ProductProfileViewModelAction.Show.AlertShow(viewModel: alertViewModel))
                                    }
                                    
                                default:
                                    if let currency = self.model.dictionaryCurrency(for: "RUB"),
                                       product.currency != currency.code {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000)) {
                                            
                                            let alertViewModel = Alert.ViewModel(title: "Закрыть вклад",
                                                                                 message: "Срок вашего вклада еще не истек. Для досрочного закрытия обратитесь в ближайший офис",
                                                                                 primary: .init(type: .default, title: "Наши офисы", action: { [weak self] in
                                                self?.action.send(ProductProfileViewModelAction.Close.Alert())
                                                self?.action.send(ProductProfileViewModelAction.Show.PlacesMap())
                                            }),
                                                                                 secondary: .init(type: .default, title: "Ок", action: {}))
                                            
                                            self.action.send(ProductProfileViewModelAction.Show.AlertShow(viewModel: alertViewModel))
                                        }
                                    } else {
                                        
                                        self.model.action.send(ModelAction.Settings.ApplicationSettings.Request())
                                    }
                                }
                            }
                            
                        case .statementOpenAccount:
                            break
                            
                        case .tariffsByAccount:
                            
                            if let productData = productData.asAccount {
                                self.openLinkURL(productData.detailedRatesUrl)
                            }
                            
                        case .termsOfService:
                            
                            if let productData = productData.asAccount {
                                self.openLinkURL(productData.detailedConditionUrl)
                            }
                        }
                        
                    default:
                        break
                    }
                    
                }
                
            }.store(in: &bindings)
    }
    
    /// Сlosing account with balance
    func bind(_ viewModel: PaymentsMeToMeViewModel) {
        
        viewModel.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self, weak viewModel] action in
                
                switch action {
                case let payload as PaymentsMeToMeAction.Response.Success:
                    
                    if let viewModel = viewModel,
                       let productIdFrom = viewModel.swapViewModel.productIdFrom,
                       let productIdTo = viewModel.swapViewModel.productIdTo,
                       let productFrom = model.product(productId: productIdFrom),
                       let productTo = model.product(productId: productIdTo)
                    {
                        model.reloadProducts(
                            productTo: productTo,
                            productFrom: productFrom
                        )
                    }
                    
                    self.bind(payload.viewModel)
                    self.success = payload.viewModel
                    
                case _ as PaymentsMeToMeAction.Response.Failed:
                    
                    makeAlert("Счет закрыт")
                    self.action.send(ProductProfileViewModelAction.Close.BottomSheet())
                    
                case let payload as PaymentsMeToMeAction.InteractionEnabled:
                    
                    guard let bottomSheet = bottomSheet else {
                        return
                    }
                    
                    bottomSheet.isUserInteractionEnabled.value = payload.isUserInteractionEnabled
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
    }
    
    /// Сlosing account without balance
    func bind(_ viewModel: CloseAccountSpinnerView.ViewModel) {
        
        viewModel.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as CloseAccountSpinnerAction.Response.Success:
                    self.fullScreenCoverState = .successZeroAccount(payload.viewModel)
                    bind(payload.viewModel)
                    self.success = payload.viewModel
                    
                case let payload as CloseAccountSpinnerAction.Response.Failed:
                    makeAlert(payload.message)
                    
                default:
                    break
                }
                
                self.action.send(ProductProfileViewModelAction.Close.AccountSpinner())
                
            }.store(in: &bindings)
    }
    
    /// Сlosing success screen
    func bind(_ viewModel: PaymentsSuccessViewModel) {
        
        viewModel.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case _ as PaymentsSuccessAction.Button.Close:
                    
                    model.action.send(ModelAction.Products.Update.Total.All())
                    self.action.send(ProductProfileViewModelAction.Close.Success())
                    self.action.send(PaymentsTransfersViewModelAction.Close.DismissAll())
                    self.rootActions?.switchTab(.main)
                    
                case _ as PaymentsSuccessAction.Button.Ready:
                    self.fullScreenCoverState = nil
                    
                case _ as PaymentsSuccessAction.Button.Repeat:
                    
                    self.action.send(ProductProfileViewModelAction.Close.Success())
                    self.rootActions?.switchTab(.payments)
                    
                default:
                    break
                }
                
                model.action.send(ModelAction.Products.Update.ForProductType(productType: .account))
                
            }.store(in: &bindings)
    }
    
    func makeProductProfileViewModel(
        product: ProductData,
        rootView: String,
        filterState: FilterState,
        dismissAction: @escaping () -> Void
    ) -> ProductProfileViewModel? {
        
        .init(
            model,
            fastPaymentsFactory: fastPaymentsFactory,
            makePaymentsTransfersFlowManager: makePaymentsTransfersFlowManager,
            userAccountNavigationStateManager: userAccountNavigationStateManager,
            sberQRServices: sberQRServices,
            productProfileServices: productProfileServices,
            qrViewModelFactory: qrViewModelFactory,
            paymentsTransfersFactory: paymentsTransfersFactory, 
            operationDetailFactory: operationDetailFactory,
            cvvPINServicesClient: cvvPINServicesClient,
            product: product, 
            productNavigationStateManager: productNavigationStateManager,
            productProfileViewModelFactory: productProfileViewModelFactory, 
            filterHistoryRequest: { _,_,_,_ in },
            filterState: filterState,
            rootView: rootView,
            dismissAction: dismissAction,
            makeOpenNewProductButtons: makeOpenNewProductButtons
        )
    }
}

//MARK: - Reducers

private extension ProductProfileViewModel {
    
    func makeAlert(_ message: String) {
        
        let alertViewModel = Alert.ViewModel(
            title: "Ошибка",
            message: message,
            primary: .init(type: .default, title: "ОК") { [weak self] in
                self?.action.send(ProductProfileViewModelAction.Close.Alert())
            })
        
        DispatchQueue.main.async { [weak self] in
            
            self?.action.send(ProductProfileViewModelAction.Show.AlertShow(viewModel: alertViewModel))
        }
    }
    
    func confirmOtp(
        cardId: CardDomain.CardId,
        actionType: ConfirmViewModel.CVVPinAction,
        phone: PhoneDomain.Phone,
        resendRequest: @escaping () -> Void
    ) {
        DispatchQueue.main.async {
            
            self.action.send(ProductProfileViewModelAction.CVVPin.ConfirmShow(
                cardId: cardId,
                actionType: actionType,
                phone: phone,
                resendOtp: resendRequest))
        }
    }
    
    func customNameAlert(
        for productType: ProductType,
        alertTitle: String
    ) ->  AlertTextFieldView.ViewModel? {
        
        let textFieldAlert: AlertTextFieldView.ViewModel = .init(
            title: alertTitle,
            message: nil,
            maxLength: 15,
            primary: .init(
                type: .default,
                title: "Ок",
                action: { [weak self] text in
                    self?.action.send(ProductProfileViewModelAction.Close.TextFieldAlert())
                    if let text = text, let product = self?.product {
                        
                        self?.model.action.send(ModelAction.Products.UpdateCustomName.Request(productId: product.activeProductId, productType: product.productType, name: text))
                    }
                }),
            secondary: .init(
                type: .default,
                title: "Отмена",
                action: { [weak self] _ in
                    
                    self?.action.send(ProductProfileViewModelAction.Close.TextFieldAlert())
                }))
        
        return textFieldAlert
    }
    
    func alertTitle(for productType: ProductType) -> String? {
        
        switch productType {
        case .card: return "Название карты"
        case .account: return "Название счета"
        default: return nil
        }
    }
    
    func alertBlockedCard(
        with card: ProductCardData
    ) -> Alert.ViewModel? {
        
        guard let cardNumber = card.number, let statusCard = card.statusCard else {
            return nil
        }
        
        let secondaryButton: Alert.ViewModel.ButtonViewModel = {
            switch statusCard {
            case .blockedUnlockNotAvailable:
                return .init(
                    type: .default,
                    title: "Контакты",
                    action: contactsAction)

            default:
                return .init(
                    type: .default,
                    title: "Oк",
                    action: { [weak self] in
                        if card.isBlocked {
                            self?.unBlock(cardId: card.cardId, cardNumber: cardNumber)
                        } else {
                            self?.block(cardId: card.cardId, cardNumber: cardNumber)
                        }
                    })
            }
        }()
        
        let alertViewModel = productProfileViewModelFactory.makeAlert(
            .init(
                statusCard: statusCard,
                primaryButton: .init(
                    type: .default,
                    title: "Отмена",
                    action: { [weak self] in
                        
                        self?.action.send(ProductProfileViewModelAction.Close.Alert())
                    }),
                secondaryButton: secondaryButton)
        )
                
        return alertViewModel
    }
    
    func block(cardId: ProductData.ID, cardNumber: String) {
        
        showSpinner()
        self.model.action.send(ModelAction.Card.Block.Request(cardId: cardId, cardNumber: cardNumber))
    }
    
    func unBlock(cardId: ProductData.ID, cardNumber: String) {
        
        showSpinner()
        self.model.action.send(ModelAction.Card.Unblock.Request(cardId: cardId, cardNumber: cardNumber))
    }
    
    func errorDepositConditionAlert(
        data: Data,
        decoder: JSONDecoder = .init()
    ) -> Alert.ViewModel {
        
        do {
            
            let responseData = try decoder.decode(ServerCommands.DepositController.GetPrintFormForDepositConditions.Response.self, from: data)
            
            if let errorMessage = responseData.errorMessage {
                
                let alertViewModel = Alert.ViewModel(title: "Форма временно недоступна",
                                                     message: errorMessage,
                                                     primary: .init(type: .cancel, title: "Наши офисы", action: { [weak self] in
                    self?.action.send(ProductProfileViewModelAction.Close.Alert())
                    self?.action.send(ProductProfileViewModelAction.Show.PlacesMap())}),
                                                     secondary: .init(type: .default, title: "ОК", action: { [weak self] in
                    self?.action.send(ProductProfileViewModelAction.Close.Alert())
                }))
                
                return alertViewModel
            } else {
                
                let alertViewModel = Alert.ViewModel(title: "Ошибка", message: "Возникла техническая ошибка. Свяжитесь с технической поддержкой банка для уточнения.", primary: .init(type: .default, title: "Ok", action: {[weak self] in
                    self?.action.send(ProductProfileViewModelAction.Close.Alert())
                }))
                return alertViewModel
            }
            
        } catch {
            
            let alertViewModel = Alert.ViewModel(
                title: "Ошибка",
                message: "Возникла техническая ошибка. Свяжитесь с технической поддержкой банка для уточнения.",
                primary: .init(type: .default, title: "Ok", action: { [weak self] in
                    self?.action.send(ProductProfileViewModelAction.Close.Alert())
                })
            )
            return alertViewModel
        }
    }
    
    func makeHistoryViewModel(
        productType: ProductType,
        productId: ProductData.ID,
        model: Model
    ) -> ProductProfileHistoryView.ViewModel? {
        
        guard productType != .loan else {
            return nil
        }
        
        return ProductProfileHistoryView.ViewModel(
            model,
            productId: productId, 
            filter: { [weak self] in
                return self?.filterState
            }
        )
    }
    
    static func accentColor(with product: ProductData) -> Color {
        
        return product.backgroundColor
    }
    
    func makeDetailViewModel(with product: ProductData) -> ProductProfileDetailView.ViewModel? {
        
        switch product {
        case let productCard as ProductCardData:
            return .init(productCard: productCard, model: model)
            
        case let productLoan as ProductLoanData:
            guard let loanData = model.loans.value.first(where: { $0.loandId == productLoan.id }) else {
                return nil
            }
            
            return .init(productLoan: productLoan, loanData: loanData, model: model)
            
        default:
            return nil
        }
    }
    
    private func openLinkURL(_ linkURL: String) {
        
        guard let url = URL(string: linkURL) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

fileprivate extension NavigationBarView.ViewModel {
    
    convenience init(
        product: ProductData,
        dismissAction: @escaping () -> Void,
        rightButtons: [ButtonItemViewModel] = []
    ) {
        self.init(
            title: ProductViewModel.name(product: product, style: .profile, creditProductName: .cardTitle),
            subtitle: Self.subtitle(with: product),
            leftItems: [BackButtonItemViewModel(icon: .ic24ChevronLeft, action: dismissAction)],
            rightItems: rightButtons,
            background: Self.accentColor(with: product),
            foreground: Self.textColor(with: product),
            backgroundDimm: .init(color: Color(hex: "1с1с1с"), opacity: 0.3))
    }
    
    static func subtitle(with productData: ProductData) -> String {
        
        guard let number = productData.displayNumber else {
            return ""
        }
        
        switch productData {
        case let productLoan as ProductLoanData:
            if let rate = NumberFormatter.persent.string(from: NSNumber(value: productLoan.currentInterestRate / 100)) {
                
                return "· \(number) · \(rate)"
                
            } else {
                
                return "· \(number)"
            }
            
        default:
            return "· \(number)"
        }
    }
    
    static func textColor(with product: ProductData) -> Color {
        
        return .mainColorsWhite
    }
    
    static func accentColor(with product: ProductData) -> Color {
        
        return product.backgroundColor
    }
    
    func update(with product: ProductData) {
        
        self.title = ProductViewModel.name(
            product: product,
            style: .profile,
            creditProductName: .productViewNavTitle
        )
        self.subtitle = Self.subtitle(with: product)
        self.foreground = Self.textColor(with: product)
        self.background = Self.accentColor(with: product)
    }
    
    func updateName(with name: String) {
        
        self.title = name
    }
}

//MARK: - Helpers

private extension ProductProfileViewModel {
    
    func showActivateCertificateAlert(action: @escaping () -> Void) {
        
        let alertViewModel = Alert.ViewModel(
            title: "Активируйте сертификат",
            message: self.model.activateCertificateMessage,
            primary:.init(
                type: .default,
                title: "Отмена",
                action: { [weak self] in self?.action.send(ProductProfileViewModelAction.Close.Alert())}
            ),
            secondary: .init(
                type: .default,
                title: "Активировать",
                action: action
            )
        )
        
        DispatchQueue.main.async { [weak self] in
            self?.action.send(ProductProfileViewModelAction.Show.AlertShow(viewModel: alertViewModel))
        }
    }
    
    func createPinCodeViewModel(
        displayNumber: PhoneDomain.Phone
    ) -> PinCodeViewModel {
        
        .init(
            title: "Введите новый PIN-код для\nкарты *\(displayNumber.rawValue)",
            pincodeLength: 4,
            getPinConfirm: pinConfirmation
        )
    }
}
// MARK: - create panel

extension ProductProfileViewModel {
    
    func createControlPanel(
        _ card: ProductCardData,
        _ buttons: ([ControlPanelButtonDetails])
    ) -> ControlPanelViewModel {
        let makeActions: ControlPanelReducer.MakeActions = .init(
            blockAction: { [weak self] in self?.controlPanelViewModel?.event(.controlButtonEvent(.blockCard(card)))}, 
            changePin: { [weak self] in
                self?.changePin($0)
            },
            contactsAction: contactsAction,
            unblockAction: {[weak self] in self?.controlPanelViewModel?.event(.controlButtonEvent(.unblockCard(card)))},
            updateProducts: { [weak self] in self?.model.handleProductsUpdateTotalProduct(.init(productType: .card))}
        )
        
        let makeViewModels: ControlPanelReducer.MakeViewModels = .init(
            stickerLanding: productProfileViewModelFactory.makeStickerLandingViewModel(
                .sticker, 
                config: .stickerDefault,
                landingActions: landingAction
            )
        )
        
        let navigationBarInfo = ControlPanelState.NavigationBarInfo(
            title: "Управление",
            subtitle: navigationTitleForControlPanel,
            action: { [weak self] in self?.link = nil }
        )
        
        return .init(
            initialState: .init(
                buttons: buttons,
                navigationBarInfo: navigationBarInfo),
            reduce: ControlPanelReducer(
                makeAlert: productProfileViewModelFactory.makeAlert,
                makeActions: makeActions,
                makeViewModels: makeViewModels, 
                getCurrencySymbol: model.dictionaryCurrency(for:)
            ).reduce(_:_:),
            handleEffect: ControlPanelEffectHandler(
                card: card,
                productProfileServices: productProfileServices,
                landingEvent: landingEvent, 
                handleModelEffect: productNavigationStateManager.handleModelEffect,
                hideKeyboard: { UIApplication.shared.hideKeyboardIfNeeds() }, 
                getCurrencySymbol: { self.model.dictionaryCurrency(for: $0)?.currencySymbol } 
                    ).handleEffect(_:_:))
    }
    
    private func landingAction(for event: LandingEvent.Sticker) -> () -> Void {
        
        switch event {
        case .goToMain:
            return handleCloseLinkAction
        case .order:
            return orderSticker
        }
    }

    func handleCloseLinkAction() {
        self.link = nil
        self.action.send(DelayWrappedAction(delayMS: 10, action: ProductProfileViewModelAction.Close.SelfView()))
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            self.rootActions?.switchTab(.main)
        }
    }
    
    func contactTransfer(_ countryID: String) {
        if let controlPanelViewModel {
            
            let paymentsViewModel = PaymentsViewModel(
                source: .direct(
                    phone: nil,
                    countryId: countryID
                ),
                model: model) {
                    controlPanelViewModel.event(.dismiss(.destination))
                }
            controlPanelViewModel.event(.bannerEvent(.contactTransfer(paymentsViewModel)))
        }
    }
    
    func migTransfer(_ countryID: String) {
        if let controlPanelViewModel {
            
            let paymentsViewModel = PaymentsViewModel(
                source: .direct(
                    phone: nil,
                    countryId: countryID
                ),
                model: model) {
                    controlPanelViewModel.event(.dismiss(.destination))
                }
            controlPanelViewModel.event(.bannerEvent(.migTransfer(paymentsViewModel)))
        }
    }

    func openDepositList() {
        
        if let controlPanelViewModel {
            
            let openDepositViewModel = OpenDepositListViewModel(
                model,
                catalogType: .deposit,
                dismissAction: {
                    controlPanelViewModel.event(.dismiss(.destination))
                }, 
                makeAlertViewModel: paymentsTransfersFactory.makeAlertViewModels.disableForCorporateCard)

            controlPanelViewModel.event(.bannerEvent(.openDepositsList(openDepositViewModel)))
        }
    }
    
    func openDeposit(_ depositId: Int ) {
        
        if let controlPanelViewModel, let openDepositViewModel = OpenDepositDetailViewModel(depositId: depositId, model: model, makeAlertViewModel: paymentsTransfersFactory.makeAlertViewModels.disableForCorporateCard) {

            controlPanelViewModel.event(.bannerEvent(.openDeposit(openDepositViewModel)))
        }
    }

    func orderSticker() {
        
        if let controlPanelViewModel {
            
            let productsCard = model.products(.card)
            
            if productsCard == nil ||
                productsCard?.contains(where: {
                    ($0 as? ProductCardData)?.isMain == true }) == false
            {
            let alertViewModel = Alert.ViewModel(
                title: "Нет карты",
                message: "Сначала нужно заказать карту.",
                primary: .init(
                    type: .default,
                    title: "Отмена",
                    action: {}),
                secondary: .init(
                    type: .default, 
                    title: "Продолжить",
                    action: {
                        
                        DispatchQueue.main.async { [weak self] in
                            
                            guard let self else { return }
                            
                            let authProductsViewModel = AuthProductsViewModel(
                                model,
                                products: model.catalogProducts.value,
                                dismissAction: { })
                            
                            controlPanelViewModel.event(.bannerEvent(.stickerEvent(.openCard(authProductsViewModel))))
                        }
                    }
                ))
                controlPanelViewModel.event(.controlButtonEvent(.showAlert(alertViewModel)))
            } else {
                
                if let rootActions {
                    
                    let view = productProfileViewModelFactory.makeNavigationOperationView(
                        dismissAll: rootActions.dismissAll
                    )()

                    controlPanelViewModel.event(.bannerEvent(.stickerEvent(.orderSticker(view))))
                }
            }
        }
    }

    func openSubscriptions() {
        
        if let controlPanelViewModel {
            
            let viewModel = productProfileViewModelFactory.makeSubscriptionsViewModel(
                { token, message in
                    
                    controlPanelViewModel.event(.alert(.cancelC2BSub(
                        message: message,
                        token: token, 
                        event: controlPanelViewModel.event
                    )))
                },
                { [weak self] token in
                    
                    self?.model.action.send(ModelAction.C2B.GetC2BDetail.Request(token: token))
                })

            controlPanelViewModel.event(.destination(.openSubscriptions(viewModel)))
        }
    }

    func createCardGuardianPanel(_ product: ProductData?) {
        
        guard let card = product?.asCard else {
            return
        }
        let panel = productProfileViewModelFactory.makeCardGuardianPanel(card)
        
        switch panel {
        case let .bottomSheet(buttons):
            bottomSheet = .init(type: .optionsPanelNew(buttons))
            
        case let .fullScreen(buttons):
            controlPanelViewModel = createControlPanel(card, buttons)
            if let controlPanelViewModel {
                controlPanelViewModel.event(.loadSVCardLanding(card))
                link = .controlPanel(controlPanelViewModel)
            }
        }
    }
}

private extension Alert.ViewModel {
    
    static func cancelC2BSub(
        message: String,
        token: SubscriptionViewModel.Token,
        event: @escaping (ControlPanelEvent) -> Void
    ) -> Self {
        
        .init(
            title: "",
            message: message,
            primary: .init(type: .cancel, title: "Отмена", action: { event(.dismiss(.alert)) }),
            secondary: .init(type: .default, title: "Отключить", action: { event(.cancelC2BSub(token))})
        )
    }
}

extension ProductProfileViewModel {
    // TODO: add real actions
    func landingEvent(_ event: LandingEvent) {
        
        switch event {
        case let .card(cardEvent):
            switch cardEvent {
            case .goToMain:
                handleCloseLinkAction()
                
            case let .openUrl(link):
                openLinkURL(link)

            case .order:
                orderSticker()
            }
            
        case let .sticker(action):
            switch action {
            case .goToMain:
                handleCloseLinkAction()

            case .order:
                orderSticker()
            }
            
        case let .bannerAction(action):
            switch action {
            case let .contact(country):
                contactTransfer(country.countryID)
                
            case .depositsList:
                openDepositList()
                
            case .depositTransfer: // см https://shorturl.at/BpUzf
                break
                
            case .landing:
               orderSticker()
                
            case .migAuthTransfer: // см https://shorturl.at/BpUzf
                break
                
            case let .migTransfer(country):
                migTransfer(country.countryID)
                
            case let .openDeposit(deposit):
                openDeposit(deposit.depositID)
                
            case .payment:
                rootActions?.openUtilityPayment(ProductStatementData.Kind.housingAndCommunalService.rawValue)
            }
        case let .listVerticalRoundImageAction(action):
            switch action {
            case .openSubscriptions:
                openSubscriptions()
            }
        case .goToBack:
            handleCloseLinkAction()
        }
    }
}

//MARK: - Types

extension ProductProfileViewModel {
    
    struct CalendarStateWrapper: Identifiable {
    
        let id: UUID
        let state: CalendarState
        
        init(
            id: UUID = .init(),
            state: CalendarState
        ) {
            self.id = id
            self.state = state
        }
    }
    
    struct HistoryState: Identifiable {
        
        var id: Int { buttonAction.hashValue }
        
        var date: Date?
        var filters: [Filter]?
        var selectedDates: (lowerDate: Date?, upperDate: Date?)
        var buttonAction: ButtonAction
        var showSheet: Sheet?
        var categories: [String]
        var applyAction: (_ lowerDate: Date?, _ upperDate: Date?) -> Void
        var calendarState: CalendarStateWrapper?
        
        enum Sheet: Identifiable {
            
            var id: ID {

                switch self {
                case .calendar:
                    return .calendar
                case .filter:
                    return .filter
                }
            }
            
            case calendar
            case filter(FilterViewModel)
            
            enum ID: Hashable {
                
                case calendar
                case filter
            }
        }
        
        enum Filter {
        
            case debit
            case credit
        }
        
        enum ButtonAction: Identifiable {
            
            case calendar
            case filter
            
            var id: ID {
                switch self {
                case .calendar:
                    return .calendar
                    
                case .filter:
                    return .filter
                }
            }
            
            enum ID: Hashable {
                
                case calendar
                case filter
            }
        }
    }
    
    enum CardGuardianPanelKind {
        
        case bottomSheet([PanelButtonDetails])
        case fullScreen([ControlPanelButtonDetails])
        
        var controlPanelButtons: [ControlPanelButtonDetails] {
            
            switch self {
            case .bottomSheet:
                return []
            case let .fullScreen(buttons):
                return buttons
            }
        }
    }
    
    struct BottomSheet: BottomSheetCustomizable {
        
        let id = UUID()
        let type: Kind
        
        let isUserInteractionEnabled: CurrentValueSubject<Bool, Never> = .init(true)
        
        var keyboardOfssetMultiplier: CGFloat {
            switch type {
            case .meToMeLegacy: return 0
            default: return 0.6
            }
        }
        
        enum Kind {
            
            case operationDetail(OperationDetailViewModel)
            case optionsPannel(ProductProfileOptionsPannelView.ViewModel)
            case optionsPanelNew([PanelButtonDetails])
            case meToMe(PaymentsMeToMeViewModel)
            case meToMeLegacy(MeToMeViewModel)
            case printForm(PrintFormView.ViewModel)
            case placesMap(PlacesViewModel)
            case info(OperationDetailInfoViewModel)
        }
    }
    
    enum Link {
        
        case productInfo(InfoProductViewModel)
        case payment(PaymentsViewModel)
        case productStatement(ProductStatementViewModel)
        case meToMeExternal(MeToMeExternalViewModel)
        case myProducts(MyProductsViewModel)
        case paymentsTransfers(Node<PaymentsTransfersViewModel>)
        case controlPanel(ControlPanelViewModel)
    }
    
    struct Sheet: Identifiable {
        
        let id = UUID()
        let type: Kind
        
        enum Kind {
            
            case printForm(PrintFormView.ViewModel)
            case placesMap(PlacesViewModel)
        }
    }
    
    enum FullScreenCoverState: Hashable & Identifiable {
        
        case changePin(ChangePin)
        case confirmOTP(ConfirmCode)
        case successChangePin(PaymentsSuccessViewModel)
        case successZeroAccount(PaymentsSuccessViewModel)
        
        var id: Case {
            
            switch self {
            case .changePin:
                return .changePin
                
            case .confirmOTP:
                return .confirmOTP
                
            case .successChangePin:
                return .successChangePin
                
            case .successZeroAccount:
                return .successZeroAccount
            }
        }
        
        typealias ResendRequest = () -> Void
        
        struct ConfirmCode {
            
            let cardId: CardDomain.CardId
            let action: ConfirmViewModel.CVVPinAction
            let phone: PhoneDomain.Phone
            let request: ResendRequest
        }
        
        struct ChangePin {
            
            let cardId: CardDomain.CardId
            let displayNumber: PhoneDomain.Phone
            let model: PinCodeViewModel
            let request: ResendRequest
        }
        enum Case: Hashable {
            
            case changePin
            case confirmOTP
            case successChangePin
            case successZeroAccount
        }
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            
            lhs.id == rhs.id
        }
        
        func hash(into hasher: inout Hasher) {
            
            hasher.combine(id)
        }
    }
}

//MARK: - Action

enum ProductProfileViewModelAction {
    
    
    enum Product {
        
        struct Activate: Action {
            
            let productId: Int
        }
        
        struct Block: Action {
            
            let productId: Int
        }
        
        struct Unblock: Action {
            
            let productId: Int
        }
        
        struct UpdateCustomName: Action {
            
            let productId: ProductData.ID
            let productType: ProductType
            let alertTitle: String
        }
        
        struct CloseAccount: Action {
            
            let productFrom: ProductData
        }
    }
    
    struct PullToRefresh: Action {}
    
    enum Show {
        
        struct OptionsPannel: Action {
            
            let viewModel: ProductProfileOptionsPannelView.ViewModel
        }
        
        struct MeToMeExternal: Action {}
        
        struct PlacesMap: Action {}
        
        struct AlertShow: Action {
            
            let viewModel: Alert.ViewModel
        }
    }
    
    enum Close {
        struct SelfView: Action {}
        struct Link: Action {}
        struct Sheet: Action {}
        struct Success: Action {}
        struct AccountSpinner: Action {}
        struct BottomSheet: Action {}
        struct DismissAll: Action {}
        struct Alert: Action {}
        struct TextFieldAlert: Action {}
    }
    
    enum MyProductsTapped {
        
        struct OpenDeposit: Action {}
    }
    
    struct TransferButtonDidTapped: Action {}
    struct DepositTransferButtonDidTapped: Action {}
    
    enum Spinner {
        
        struct Show: Action {}
        struct Hide: Action {}
    }
    
    enum CVVPin {
        
        struct ChangePin: Action {
            
            let cardId: CardDomain.CardId
            let phone: PhoneDomain.Phone
        }
        
        struct ConfirmShow: Action {
            
            let cardId: CardDomain.CardId
            let actionType: ConfirmViewModel.CVVPinAction
            let phone: PhoneDomain.Phone
            let resendOtp: () -> Void
        }
    }
}

extension ProductProfileViewModel {
    
    private func blockCard(with productData: ProductData?) {
        
        guard let card = productData?.asCard, let alertViewModel = alertBlockedCard(with: card) else {
            return
        }
        event(.alert(.delayAlertViewModel(alertViewModel)))
    }
    
    private func unblockCard(with productData: ProductData?) {
        
        blockCard(with: productData)
    }
    
    private func checkCertificate(
        _ cardId: CardDomain.CardId,
        certificate: CVVPINServicesClient,
        _ productCard: ProductCardData
    ) {
        certificate.checkFunctionality { [weak self] result in
            
            guard let self else { return }
            
            handleCheckCertificateResult(cardId, result, displayNumber: .init(productCard.displayNumber ?? ""))
        }
    }
    
    func changePin(_ productCard: ProductCardData) {
        if productCard.statusCard != .active {
            event(.alert(.delayAlert(.showBlockAlert)))
        } else {
            checkCertificate(.init(productCard.id), certificate: cvvPINServicesClient, productCard)
        }
    }
    
    func handlePanelButtonType(
        _ type: PanelButtonType,
        _ productCard: ProductCardData
    ) {
        switch type {
        case .block:
            self.action.send(ProductProfileViewModelAction.Product.Block(productId: productCard.id))
            
        case .unblock:
            self.action.send(ProductProfileViewModelAction.Product.Unblock(productId: productCard.id))
            
        case .changePin:
            changePin(productCard)
            
        case .visibility:
            self.model.action.send(ModelAction.Products.UpdateVisibility(productId: productCard.id, visibility: !productCard.isVisible))
        }
    }
    
    func handleCheckCertificateResult(
        _ cardId: CardDomain.CardId,
        _ result: Result<Void, CheckCVVPINFunctionalityError>,
        displayNumber: PhoneDomain.Phone
    ) {
        switch result {
            
        case let .failure(pinError):
            handlePinError(cardId, pinError, displayNumber)
            
        case .success:
            fullScreenCoverState = .changePin(.init(
                cardId: cardId,
                displayNumber: displayNumber,
                model: self.createPinCodeViewModel(displayNumber: displayNumber),
                request: self.resendOtpForPin
            ))
        }
    }
    
    func resendOtpForPin() {
        
        cvvPINServicesClient.getPINConfirmationCode { [weak self] result in
            
            guard let self else { return }
            
            Task { @MainActor in
                if case let .failure(error) = result {
                    switch error {
                    case let .server(_, errorMessage):
                        self.makeAlert(errorMessage)
                    case .serviceFailure, .activationFailure:
                        self.makeAlert("Техническая ошибка.")
                    }
                }
            }
        }
    }
    
    func showSpinner() {
        
        DispatchQueue.main.async { [weak self] in
            
            guard let self else { return }
            
            switch self.link {
                
            case .none:
                self.action.send(DelayWrappedAction(
                    delayMS: 10,
                    action:ProductProfileViewModelAction.Spinner.Show()))
                
            case let .some(destination):
                switch destination {
                case let .productInfo(productInfoViewModel):
                    productInfoViewModel.action.send(DelayWrappedAction(
                        delayMS: 10,
                        action: InfoProductModelAction.Spinner.Show()))

                case let .controlPanel(controlPanel):
                    controlPanel.event(.showSpinner)
                    
                default:
                    self.action.send(DelayWrappedAction(
                        delayMS: 10,
                        action:ProductProfileViewModelAction.Spinner.Show()))
                }
            }
        }
    }
    
    func hideSpinner() {
        
        switch self.link {
            
        case .none:
            self.action.send(DelayWrappedAction(
                delayMS: 10,
                action:ProductProfileViewModelAction.Spinner.Hide()))
            
        case let .some(destination):
            switch destination {
            case let .productInfo(productInfoViewModel):
                productInfoViewModel.action.send(DelayWrappedAction(
                    delayMS: 10,
                    action: InfoProductModelAction.Spinner.Hide()))
                
            case let .controlPanel(controlPanel):
                controlPanel.event(.hideSpinner)
                
            default:
                self.action.send(DelayWrappedAction(
                    delayMS: 10,
                    action:ProductProfileViewModelAction.Spinner.Hide()))
            }
        }
    }
    
    func activateCertificateAction(
        cvvPINServicesClient: CVVPINServicesClient,
        cardId: CardDomain.CardId,
        actionType: ConfirmViewModel.CVVPinAction
    ) {
        cvvPINServicesClient.activate { [weak self] result in
            
            guard let self else { return }
            
            hideSpinner()
            
            switch result {
            case let .failure(error):
                switch error {
                case let .server(_, errorMessage):
                    self.makeAlert(errorMessage)
                case .serviceFailure:
                    self.makeAlert("Техническая ошибка.")
                }
                
            case let .success(phone):
                self.confirmOtp(
                    cardId: cardId,
                    actionType: actionType,
                    phone: phone,
                    resendRequest: self.resendOtp
                )
            }
        }
    }
    
    func showActivateCertificate(
        cardId: CardDomain.CardId,
        actionType: ConfirmViewModel.CVVPinAction
    ) {
        let action: () -> Void = { [weak self] in
            
            guard let self else { return }
            
            self.showSpinner()
            
            self.activateCertificateAction(
                cvvPINServicesClient: self.cvvPINServicesClient,
                cardId: cardId,
                actionType: actionType
            )
        }
        self.showActivateCertificateAlert(action: action)
    }
    
    func resendOtp() {
        
        self.cvvPINServicesClient.activate { [weak self] result in
            
            guard let self else { return }
            
            Task { @MainActor in
                if case let .failure(error) = result {
                    switch error {
                    case let .server(_, errorMessage):
                        self.makeAlert(errorMessage)
                    case .serviceFailure:
                        self.makeAlert("Техническая ошибка.")
                    }
                }
            }
        }
    }
    
    func handlePinError(
        _ cardId: CardDomain.CardId,
        _ pinError: (CheckCVVPINFunctionalityError),
        _ displayNumber: PhoneDomain.Phone
    ) {
        switch pinError {
            
        case .activationFailure:
            showActivateCertificate(cardId: cardId, actionType: .changePin(displayNumber))
            
        case let .server(_, errorMessage):
            makeAlert(errorMessage)
            
        case .serviceFailure:
            makeAlert("Истеклo время\nожидания ответа")
        }
    }
    
    private func successScreenForChangePin() {
        
        let success = Payments.Success(
            status: .success,
            title: "PIN-код успешно изменен",
            titleForActionButton: "Готово"
        )
        
        let successViewModel = PaymentsSuccessViewModel(paymentSuccess: success, model)
        self.fullScreenCoverState = .successChangePin(successViewModel)
        bind(successViewModel)
    }
    
    private func errorScreenForChangePin() {
        
        let success = Payments.Success(
            status: .error,
            title: "Ошибка",
            subTitle: "Не удалось изменить PIN-код.\nПовторите попытку позднее",
            titleForActionButton: "Готово"
        )
        
        let successViewModel = PaymentsSuccessViewModel(paymentSuccess: success, model)
        self.fullScreenCoverState = .successChangePin(successViewModel)
        bind(successViewModel)
    }
}

extension ProductProfileViewModel {
    
    typealias ShowCVVCompletion = (CardInfo.CVV?) -> Void
    
    func showCvvByTap(
        cardId: CardDomain.CardId,
        completion: @escaping ShowCVVCompletion
    ) {
        if productData?.productStatus == .active || productData?.productStatus == .notVisible {
            cvvPINServicesClient.showCVV(
                cardId: cardId.rawValue
            ) { [weak self] result in
                
                guard let self else { return }
                
                switch result {
                case let .failure(error):
                    handle(error: error, forCardId: cardId)
                    completion(nil)
                    
                case let .success(cvv):
                    completion(cvv)
                }
            }
        } else {
            event(.alert(.delayAlert(.showBlockAlert)))
        }
    }
    
    func handle(
        error: ShowCVVError,
        forCardId cardId: CardDomain.CardId
    ) {
        switch error {
        case .activationFailure:
            // show activate Certificate
            self.showActivateCertificate(cardId: cardId, actionType: .showCvv)
            
        case let .server(code, _):
            // show Alert with message
            self.makeAlert("\(String.cvvNotReceived).\nКод ошибки \(code).")
            
        case .serviceFailure:
            // show Alert
            self.makeAlert("\(String.cvvNotReceived).\n\(String.tryLater).")
        }
    }
}

extension ProductProfileViewModel {
    
    func handleEffect(_ effect: ProductProfileFlowManager.Effect) {
        
        productNavigationStateManager.handleEffect(effect) { [weak self] event in
            
            switch event {
                
            case let .showAlert(alert):
                self?.event(.alert(.showAlert(alert)))
            case let .showBottomSheet(bottomSheet):
                self?.event(.bottomSheet(.showBottomSheet(bottomSheet)))
            case let .history(event):
                self?.event(.history(event))
            }
        }
    }
    
    func event(_ event: ProductProfileFlowEvent) {
        
        let state = ProductProfileFlowState(
            alert: alert,
            bottomSheet: bottomSheet,
            history: historyState,
            filter: filterState,
            payment: .sample
        )
        
        let (newState, effect) = productNavigationStateManager.reduce(state, event)
        
        alertSubject.send(newState.alert)
        bottomSheetSubject.send(newState.bottomSheet)
        historySubject.send(newState.history)
        filterSubject.send(newState.filter)
        
        if let effect {
            
            handleEffect(effect)
        }
    }
    
    func showProductInfo(_ productData: ProductData) {
        
        let productInfoViewModel = productProfileViewModelFactory.makeInfoProductViewModel(
            .init(
                model: model,
                productData: productData,
                info: false,
                showCVV: { [weak self] cardId, completion in
                    
                    guard let self else { return }
                    
                    self.showCvvByTap(
                        cardId: cardId,
                        completion: completion)
                },
                events: { event in self.event(.alert(event)) }
            )
        )
        self.link = .productInfo(productInfoViewModel)
        self.bind(product: productInfoViewModel)
    }
    
    func showProductStatement(_ productData: ProductData) {
        let productStatementViewModel = ProductStatementViewModel(
            product: productData,
            closeAction: { [weak self] in self?.action.send(ProductProfileViewModelAction.Close.Link())},
            getUImage: { self.model.images.value[$0]?.uiImage }
        )
        self.link = .productStatement(productStatementViewModel)
    }
    
    func showPaymentOurBank(_ productData: ProductCardData) {
        switch productData.cardType {
        case .additionalOther:
            event(.alert(.delayAlert(.showServiceOnlyOwnerCard)))
            
        default:
            
            if model.needDisableForIndividualBusinessmanMainCardAlert(
                product: productData,
                with: .generalToWithDepositAndIndividualBusinessmanMain) {
                event(.alert(.delayAlert(.showServiceOnlyIndividualCard)))
            } else {
                guard let viewModel = PaymentsMeToMeViewModel(
                    model,
                    mode: .makePaymentTo(productData, 0.0))
                else { return }
                
                bind(viewModel)
                
                event(.bottomSheet(.delayBottomSheet(.init(type: .meToMe(viewModel)))))
            }
        }
    }
    
    func showPaymentAnotherBank(_ productData: ProductCardData) {
        switch productData.cardType {
            
        case .individualBusinessmanMain:
            self.event(.alert(.delayAlert(.showServiceOnlyIndividualCard)))

        case .additionalSelf, .additionalOther:
            self.event(.alert(.delayAlert(.showServiceOnlyMainCard)))
            
        default:
            let meToMeExternalViewModel = MeToMeExternalViewModel(
                productTo: productData,
                closeAction: { [weak self] in
                    self?.action.send(ProductProfileViewModelAction.Close.Link())
                },
                getUImage: { self.model.images.value[$0]?.uiImage }
            )
            self.link = .meToMeExternal(meToMeExternalViewModel)
        }
    }
    
    func event(_ event: ProductProfileFlowManager.ButtonEvent) {
        
        self.bottomSheet = nil

        guard let productData = model.product(productId: event.productID) else { return }
        
        switch (event.type, productData.asCard) {
        case (.accountDetails, _):
            showProductInfo(productData)
            
        case (.accountStatement, _):
            showProductStatement(productData)
            
        case let (.accountOurBank, .some(card)):
                        
            showPaymentOurBank(card)
            
        case let (.accountAnotherBank, .some(card)):
                        
            showPaymentAnotherBank(card)
            
        case let (.cardGuardian, .some(card)):
            
            switch card.statusCard {
            case .blockedUnlockAvailable, .blockedUnlockNotAvailable:
                self.handlePanelButtonType(.unblock, card)

            case .active:
                self.handlePanelButtonType(.block, card)
                
            default:
                return
            }

        case let (.changePin, .some(card)):
            
            self.handlePanelButtonType(.changePin, card)

        case let (.visibility, .some(card)):
            
            self.handlePanelButtonType(.visibility, card)
            
        default:
            return
        }
    }
}

extension ProductProfileViewModel {
    
    func makeSliderViewModel() -> ActivateSliderViewModel {
        
        .init(
            initialState: .initialState,
            reduce: CardActivateReducer.default,
            handleEffect: CardActivateEffectHandler(handleCardEffect: CardEffectHandler(
                activate: unblockCardService
            ).handleEffect(_:_:)).handleEffect(_:_:)
        )
    }
    
    private func unblockCardService(
        cardID: ProductData.ID,
        completion: @escaping CardEffectHandler.ActivateCompletion
    ) {
        
        let cardNumber: String = model.product(productId: cardID)?.asCard?.number ?? ""
        
        productProfileServices.createUnblockCardService.createUnblockCard(.init(cardId: .init(cardID), cardNumber: .init(cardNumber))) { result in
            switch result {
            case .failure:
                completion(.serverError("failure"))
                
            case .success:
                completion(.success)
            }
        }
    }
}

extension ProductProfileViewModel {
    
    func calendarDayStart() -> Date {
        
        if product.productType == .card {
            return Calendar.current.date(from: .init(calendar: .current, year: 2024, month: 8, day: 27))!
        } else {
            return model.product(productId: product.activeProductId)?.openDate ?? Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        }
    }
}

extension Date {

    static let bankOpenDate: Date = {
        
        let components = DateComponents(year: 1992, month: 5, day: 27)
        return Calendar.current.date(from: components)!
    }()
}

extension Model {

    func calendarDayStart(
        _ productId: ProductData.ID
    ) -> Date {
        
        product(productId: productId)?.calendarDayStart() ?? .bankOpenDate
    }
    
}

extension ProductData {
    
    func calendarDayStart(
    ) -> Date {
        
        if productType == .card {
            return .bankOpenDate
        } else {
            return openDate ?? Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        }
    }
}

extension Model {
    
    func historyCategories(
        range: ClosedRange<Date>,
        productId: ProductData.ID
    ) -> [String] {
                
        if let statements = statements.value[productId]?.statements.filter({ range.contains($0.dateValue)} ) {
            
            return Array(Set(statements.map(\.groupName)))
        } else {
            return []
        }
    }
}
