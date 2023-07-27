//
//  ProductProfileViewModel.swift
//  ForaBank
//
//  Created by Дмитрий on 09.03.2022.
//

import Foundation
import Combine
import SwiftUI
import PDFKit
import PinCodeUI

enum PinError: Error {
    
    case certificate
    case connectivity
}

typealias CertificateClient = CheckCertificateClient & ActivateCertificateClient

protocol CheckCertificateClient {
    
    func checkCertificate(completion: @escaping (Result<Void, PinError>) -> Void)
}

protocol ActivateCertificateClient {
    
    func activateCertificate(completion: @escaping (Result<Void, Error>) -> Void)
}

final class HappyCertificateClient: CertificateClient {
    
    func checkCertificate(completion: @escaping (Result<Void, PinError>) -> Void) {
        completion(.success(()))
    }

    func activateCertificate(completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.success(()))
    }
}

final class HappyCheckSadActivateCertificateClient: CertificateClient {
    
    func checkCertificate(completion: @escaping (Result<Void, PinError>) -> Void) {
        completion(.success(()))
    }

    func activateCertificate(completion: @escaping (Result<Void, Error>) -> Void) {
        
        struct ActivationError: Error {}
        completion(.failure(ActivationError()))
    }
}

final class SadCertificateClient: CertificateClient {
    
    func checkCertificate(completion: @escaping (Result<Void, PinError>) -> Void) {
        
        completion(.failure(PinError.certificate))
    }
    
    func activateCertificate(completion: @escaping (Result<Void, Error>) -> Void) {
        
        completion(.success(()))
    }
}

// MARK: - getPinConfirmationCode

func getPinConfirmationCodePublisher() -> PinCodeViewModel.ConfirmationPublisher {
    
    Just(.init(value: "+1...90"))
        .setFailureType(to: Error.self)
        .eraseToAnyPublisher()
}

// MARK: - getPinConfirmationCode

func getProcessingSessionCodePublisher() -> PinCodeViewModel.ConfirmationPublisher {
    
    Just(.init(value: "+1...80"))
        .setFailureType(to: Error.self)
        .eraseToAnyPublisher()
}

class ProductProfileViewModel: ObservableObject {
    
    let action: PassthroughSubject<Action, Never> = .init()
    
    let navigationBar: NavigationBarView.ViewModel
    @Published var product: ProductProfileCardView.ViewModel
    @Published var buttons: ProductProfileButtonsView.ViewModel
    @Published var detail: ProductProfileDetailView.ViewModel?
    @Published var history: ProductProfileHistoryView.ViewModel?
    @Published var operationDetail: OperationDetailViewModel?
    @Published var accentColor: Color
    
    @Published var bottomSheet: BottomSheet?
    @Published var link: Link? { didSet { isLinkActive = link != nil } }
    @Published var isLinkActive: Bool = false
    @Published var sheet: Sheet?
    @Published var alert: Alert.ViewModel?
    @Published var textFieldAlert: AlertTextFieldView.ViewModel?
    @Published var spinner: SpinnerView.ViewModel?
    
    @Published var success: PaymentsSuccessViewModel?
    @Published var successZeroAccount: ZeroAccount?

    @Published var closeAccountSpinner: CloseAccountSpinnerView.ViewModel?

    var rootActions: RootViewModel.RootActions?
    var rootView: String
    
    private var historyPool: [ProductData.ID : ProductProfileHistoryView.ViewModel]
    private let model: Model
    private var bindings = Set<AnyCancellable>()
    
    private var productData: ProductData? {
        model.products.value.values.flatMap({ $0 }).first(where: { $0.id == self.product.activeProductId })
    }
    
    private let certificateClient: CertificateClient
    
    init(navigationBar: NavigationBarView.ViewModel,
         product: ProductProfileCardView.ViewModel,
         buttons: ProductProfileButtonsView.ViewModel,
         detail: ProductProfileDetailView.ViewModel?,
         history: ProductProfileHistoryView.ViewModel?,
         operationDetail: OperationDetailViewModel? = nil,
         accentColor: Color = .purple,
         historyPool: [ProductData.ID : ProductProfileHistoryView.ViewModel] = [:],
         model: Model = .emptyMock,
         rootView: String,
         certificateClient: CertificateClient
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
        self.rootView = rootView
        self.certificateClient = certificateClient
        
        LoggerAgent.shared.log(level: .debug, category: .ui, message: "ProductProfileViewModel initialized")
    }
    
    deinit {
        
        LoggerAgent.shared.log(level: .debug, category: .ui, message: "ProductProfileViewModel deinitialized")
    }
    
    convenience init?(
        _ model: Model,
        product: ProductData,
        rootView: String,
        certificateClient: CertificateClient,
        dismissAction: @escaping () -> Void
    ) {
        
        guard let productViewModel = ProductProfileCardView.ViewModel(model, productData: product) else {
            return nil
        }
        
        // status bar
        let navigationBar = NavigationBarView.ViewModel(product: product, dismissAction: dismissAction)
        let buttons = ProductProfileButtonsView.ViewModel(with: product, depositInfo: model.depositsInfo.value[product.id])
        let accentColor = Self.accentColor(with: product)
        
        self.init(navigationBar: navigationBar, product: productViewModel, buttons: buttons, detail: nil, history: nil, accentColor: accentColor, model: model, rootView: rootView, certificateClient: certificateClient)
        
        // detail view model
        self.detail = makeDetailViewModel(with: product)
        
        // history view model
        let historyViewModel = makeHistoryViewModel(productType: product.productType, productId: product.id, model: model)
        self.history = historyViewModel
        self.historyPool[product.id] = historyViewModel
        bind(product: productViewModel)
        bind(history: historyViewModel)
        bind(detail: detail)
        bind(buttons: buttons)

        bind()
    }
}

//MARK: - Bindings

private extension ProductProfileViewModel {
    
    func bind() {
        
        // TransferButtonDidTapped
        
        action
            .compactMap { $0 as? ProductProfileViewModelAction.TransferButtonDidTapped }
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                
                model.setPreferredProductID(to: product.activeProductId)
                let paymentsTransfersViewModel = PaymentsTransfersViewModel(
                    model: model,
                    isTabBarHidden: true,
                    mode: .link
                )
                link = .paymentsTransfers(paymentsTransfersViewModel)
                
            }.store(in: &bindings)
        
        $isLinkActive
            .sink { [unowned self] value in
                
                if value == false {
                    
                    model.setPreferredProductID(to: nil)
                }
                
            }.store(in: &bindings)
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                switch action {
                case _ as ProductProfileViewModelAction.PullToRefresh:
                    model.action.send(ModelAction.Products.Update.Fast.Single.Request(productId: product.activeProductId))
                    model.action.send(ModelAction.Statement.List.Request(productId: product.activeProductId, direction: .latest))
                    switch product.productType {
                    case .deposit:
                        model.action.send(ModelAction.Deposits.Info.Single.Request(productId: product.activeProductId))
                    case .loan:
                        model.action.send(ModelAction.Loans.Update.Single.Request(productId: product.activeProductId))
                        
                    default:
                        break
                    }
                    
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
                        
                        if let productFrom = from as? ProductAccountData {
                            
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
                    successZeroAccount = nil
                    success = nil
                    
                case _ as ProductProfileViewModelAction.Close.AccountSpinner:
                    closeAccountSpinner = nil
                    
                case _ as ProductProfileViewModelAction.Close.BottomSheet:
                    bottomSheet = nil
                    
                case _ as PaymentsTransfersViewModelAction.Close.DismissAll:
                    
                    withAnimation {
                        NotificationCenter.default.post(name: .dismissAllViewAndSwitchToMainTab, object: nil)
                    }
                    
                case _ as ProductProfileViewModelAction.Close.Alert:
                    alert = nil
                    
                case _ as ProductProfileViewModelAction.Close.TextFieldAlert:
                    textFieldAlert = nil
                    
                case _ as ProductProfileViewModelAction.Show.MeToMeExternal:
                    if let productData = productData as? ProductLoanData, let loanAccount = self.model.products.value[.account]?.first(where: {$0.number == productData.settlementAccount}) {
                        
                        let meToMeExternalViewModel = MeToMeExternalViewModel(productTo: loanAccount, closeAction: { [weak self] in self?.action.send(ProductProfileViewModelAction.Close.Link())})
                        self.link = .meToMeExternal(meToMeExternalViewModel)
                    } else {
                        
                        let meToMeExternalViewModel = MeToMeExternalViewModel(productTo: productData, closeAction: { [weak self] in
                            self?.action.send(ProductProfileViewModelAction.Close.Link())
                        })
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
                    
                case let payload as ModelAction.Products.UpdateCustomName.Response:
                    
                    switch payload {
                    case .complete(productId: let productId, name: let name):
                        guard let product = model.products.value.values.flatMap({ $0 }).first(where: { $0.id == productId }) else {
                            return
                        }
                        
                        withAnimation {
                            
                            navigationBar.updateName(with: name)
                            accentColor = Self.accentColor(with: product)
                        }
                        
                    case .failed(message: let message):
                        alert = .init(title: "Ошибка", message: message, primary: .init(type: .default, title: "Ok", action: { [weak self] in
                            self?.alert = nil
                        }))
                    }
                    
                case let payload as ModelAction.Card.Block.Response:
                    switch payload {
                    case .success:
                        self.model.action.send(ModelAction.Products.Update.ForProductType.init(productType: .card))
                        
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
                    switch payload {
                    case .success(data: _):
                        
                        guard let productData = productData else {
                            return
                        }
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
                
                withAnimation {
                    buttons.update(with: productData, depositInfo: model.depositsInfo.value[productData.id])
                }
                
            }.store(in: &bindings)
        
        model.loans
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] loans in
                
                guard product.productType == .loan else {
                    return
                }
                
                if let productLoan = model.products.value[.loan]?.first(where: { $0.id == product.activeProductId }) as? ProductLoanData,
                   let loanData = loans.first(where: { $0.loandId == product.activeProductId}) {
                    
                    withAnimation {
                        
                        if let detail = detail {
                            
                            detail.update(productLoan: productLoan, loanData: loanData, model: model)
                            
                        } else {
                            
                            detail = .init(productLoan: productLoan, loanData: loanData, model: model)
                            bind(detail: detail)
                        }
                    }
                    
                } else {
                    
                    withAnimation {
                        detail = nil
                    }
                }
                
            }.store(in: &bindings)
        
        product.$activeProductId
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] activeProductId in
                
                guard let product = model.products.value.values.flatMap({ $0 }).first(where: { $0.id == activeProductId }) else {
                    return
                }
                
                if let deposit = self.model.products.value.values.flatMap({ $0 }).first(where: { $0.id == self.product.activeProductId }) as? ProductDepositData, model.depositsInfo.value[self.product.activeProductId] == nil {
                    
                    self.model.action.send(ModelAction.Deposits.Info.Single.Request(productId: deposit.id))
                }
                // status bar update
                withAnimation {
                    
                    navigationBar.update(with: product)
                    accentColor = Self.accentColor(with: product)
                }
                
                // buttons update
                withAnimation {
                    buttons.update(with: product, depositInfo: model.depositsInfo.value[product.id])
                }
                
                // detail update
                withAnimation {
                    detail = makeDetailViewModel(with: product)
                }
                
                bind(detail: detail)
                
                // history update
                if let historyViewModel = historyPool[activeProductId] {
                    
                    withAnimation {
                        history = historyViewModel
                    }
                    
                } else {
                    
                    let historyViewModel = makeHistoryViewModel(productType: product.productType, productId: activeProductId, model: model)
                    
                    withAnimation {
                        history = historyViewModel
                    }
                    
                    historyPool[activeProductId] = historyViewModel
                    bind(history: historyViewModel)
                }
                
                if product.productType == .card || product.productType == .account {
                    
                    guard let alertTitle = alertTitle(for: product.productType) else { return }
                    
                    withAnimation {
                        
                        navigationBar.rightItems = [ NavigationBarView.ViewModel.ButtonItemViewModel(icon: .ic16Edit2, action: { [weak self] in
                            
                            self?.action.send(ProductProfileViewModelAction.Product.UpdateCustomName(productId: product.id, productType: product.productType, alertTitle: alertTitle))
                        })]
                    }
                } else {
                    
                    withAnimation {
                        
                        navigationBar.rightItems = []
                    }
                }
                
            }.store(in: &bindings)
    }
    
    func bind(product: ProductProfileCardView.ViewModel) {
        
        product.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case _ as ProductProfileCardViewModelAction.MoreButtonTapped:
                    
                    if self.rootView == "\(MyProductsViewModel.self)" {
                        self.action.send(ProductProfileViewModelAction.Close.SelfView())
                        
                    } else {
                        let myProductsViewModel = MyProductsViewModel(model)
                        myProductsViewModel.rootActions = rootActions
                        link = .myProducts(myProductsViewModel)
                    }
                    
                case let payload as ProductProfileCardViewModelAction.ShowAlert:
                    self.alert = Alert.ViewModel(title: payload.title, message: payload.message, primary: .init(type: .default, title: "Ок", action: {}))
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
        
    }
    
    func bind(history: ProductProfileHistoryView.ViewModel?) {
        
        guard let history = history else {
            return
        }
        history.action
            .receive(on: DispatchQueue.main)
            .sink { [weak self] action in
                
                guard let self = self else { return }
                
                switch action {
                case let payload as ProductProfileHistoryViewModelAction.DidTapped.Detail:
                    guard let storage = self.model.statements.value[self.product.activeProductId],
                          let statementData = storage.statements.first(where: { $0.id == payload.statementId }),
                          let productData = self.model.products.value.values.flatMap({ $0 }).first(where: { $0.id == self.product.activeProductId }),
                          let operationDetailViewModel = OperationDetailViewModel(productStatement: statementData, product: productData, model: self.model) else {
                        
                        return
                    }
                    
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
                            
                            let optionsPannelViewModel = ProductProfileOptionsPannelView.ViewModel(title: "Пополнить", buttonsTypes: [.refillFromOtherBank, .refillFromOtherProduct], productType: product.productType)
                            self.action.send(ProductProfileViewModelAction.Show.OptionsPannel(viewModel: optionsPannelViewModel))
                            
                        } else {
                            
                            let alertView = Alert.ViewModel(title: "Невозможно пополнить",
                                                            message: "Вклад не предусматривает возможности пополнения.\nПодробнее в информации по вкладу в деталях",
                                                            primary: .init(type: .default, title: "ОК", action: { [weak self] in self?.action.send(ProductProfileViewModelAction.Close.Alert())}))
                            self.alert = .init(alertView)
                        }
                        
                    case .topRight:
                        switch product.productType {
                        case .card, .account:
                            self.action.send(ProductProfileViewModelAction.TransferButtonDidTapped())
                            
                        case .deposit:
                            guard let depositProduct = self.model.products.value.values.flatMap({ $0 }).first(where: { $0.id == self.product.activeProductId }) as? ProductDepositData,
                                  let depositInfo = model.depositsInfo.value[self.product.activeProductId],
                                  let transferType = depositProduct.availableTransferType(with: depositInfo) else {
                                return
                            }
                            
                            switch transferType {
                            case .remains:
                                // перевести

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
                            
                        default:
                            break
                        }
                        
                        
                    case .bottomLeft:
                        switch product.productType {
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
                            
                            guard let productCard = productData as? ProductCardData else {
                                return
                            }

                            let buttonType: ProductProfileOptionsPannelView.ViewModel.ButtonType = productCard.isBlocked ? .card(.unblock) : .card(.block)
                            let optionsPannelViewModel = ProductProfileOptionsPannelView.ViewModel(buttonsTypes: [buttonType, .card(.changePin)], productType: product.productType)
                            self.action.send(ProductProfileViewModelAction.Show.OptionsPannel(viewModel: optionsPannelViewModel))
                            
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
            
    
    
    func bind(optionsPannel: ProductProfileOptionsPannelView.ViewModel) {
        
        optionsPannel.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                self.action.send(ProductProfileViewModelAction.Close.BottomSheet())
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                    
                    guard let productData = self.productData else {
                        return
                    }
                    
                    switch action {
                    case let payload as ProductProfileOptionsPannelViewModelAction.ButtonTapped:
                        switch payload.buttonType {
                        case .requisites:
                            let productInfoViewModel = InfoProductViewModel(model: self.model, product: productData, info: false)
                            self.link = .productInfo(productInfoViewModel)
                            
                        case .info:
                            let productInfoViewModel = InfoProductViewModel(model: self.model, product: productData, info: true)
                            self.link = .productInfo(productInfoViewModel)
                            
                        case .statement:
                            let productStatementViewModel = ProductStatementViewModel(product: productData, closeAction: { [weak self] in self?.action.send(ProductProfileViewModelAction.Close.Link())})
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
                            
                            if let productData = productData as? ProductAccountData {
                                self.openLinkURL(productData.detailedRatesUrl)
                            }
                            
                        case .termsOfService:
                            
                            if let productData = productData as? ProductAccountData {
                                self.openLinkURL(productData.detailedConditionUrl)
                            }
                          
                        case let .card(type):
                            
                            guard let productCard = productData as? ProductCardData else { return }

                            self.handleCardType(type, productCard)
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
                       let productIdTo = viewModel.swapViewModel.productIdTo {
                            model.action.send(ModelAction.Products.Update.Fast.Single.Request(productId: productIdFrom))
                            model.action.send(ModelAction.Products.Update.Fast.Single.Request(productId: productIdTo))
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
                    self.successZeroAccount = ZeroAccount(viewModel: payload.viewModel)
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
                    
                case _ as PaymentsSuccessAction.Button.Repeat:
                    
                    self.action.send(ProductProfileViewModelAction.Close.Success())
                    self.rootActions?.switchTab(.payments)
                    
                default:
                    break
                }
                
                model.action.send(ModelAction.Products.Update.ForProductType(productType: .account))

            }.store(in: &bindings)
    }
}

//MARK: - Reducers

private extension ProductProfileViewModel {
    
    func makeAlert(_ message: String) {
        
        let alertViewModel = Alert.ViewModel(title: "Ошибка", message: message, primary: .init(type: .default, title: "ОК") { [weak self] in
            self?.action.send(ProductProfileViewModelAction.Close.Alert())
        })
        
        alert = .init(alertViewModel)
    }

    func customNameAlert(for productType: ProductType, alertTitle: String) ->  AlertTextFieldView.ViewModel? {
        
        let textFieldAlert: AlertTextFieldView.ViewModel = .init(
            title: alertTitle,
            message: nil,
            maxLength: 15,
            primary: .init(type: .default,
                           title: "Ок",
                           action: { [weak self] text in
                               self?.action.send(ProductProfileViewModelAction.Close.TextFieldAlert())
                               if let text = text, let product = self?.product {
                                   
                                   self?.model.action.send(ModelAction.Products.UpdateCustomName.Request(productId: product.activeProductId, productType: product.productType, name: text))
                               }
                           }),
            secondary: .init(type: .default,
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
    
    func alertBlockedCard(with product: ProductData) -> Alert.ViewModel? {
        
        guard let product = product as? ProductCardData, let cardNumber = product.number else {
            return nil
        }
        
        var description: String? {
            switch product.isBlocked {
            case true: return nil
            case false: return "Карту можно будет разблокировать в приложении или в колл-центре"
            }
        }
        
        let alertViewModel: Alert.ViewModel = .init(title: alertTitle(),
                                                    message: description,
                                                    primary: .init(type: .default,
                                                                   title: "Отмена",
                                                                   action: { [weak self] in
            
            self?.action.send(ProductProfileViewModelAction.Close.Alert())
        }),
                                                    secondary: .init(type: .default,
                                                                     title: "Oк",
                                                                     action: { [weak self] in
            if product.isBlocked {
                
                self?.model.action.send(ModelAction.Card.Unblock.Request(cardId: product.cardId, cardNumber: cardNumber))
                
            } else {
                
                self?.model.action.send(ModelAction.Card.Block.Request(cardId: product.cardId, cardNumber: cardNumber))
            }
            
        }))
        
        func alertTitle() -> String {

           product.isBlocked ? "Разблокировать карту?" : "Заблокировать карту?"
        }
        
        return alertViewModel
    }
    
    func errorDepositConditionAlert(data: Data, decoder: JSONDecoder = .init()) -> Alert.ViewModel {
        
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
            
            let alertViewModel = Alert.ViewModel(title: "Ошибка", message: "Возникла техническая ошибка. Свяжитесь с технической поддержкой банка для уточнения.", primary: .init(type: .default, title: "Ok", action: {[weak self] in
                self?.action.send(ProductProfileViewModelAction.Close.Alert())
            }))
            return alertViewModel
        }
    }

    func makeHistoryViewModel(productType: ProductType, productId: ProductData.ID, model: Model) -> ProductProfileHistoryView.ViewModel? {
    
        guard productType != .loan else {
            return nil
        }
        
        return ProductProfileHistoryView.ViewModel(model, productId: productId)
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
    
    convenience init(product: ProductData, dismissAction: @escaping () -> Void, rightButtons: [ButtonItemViewModel] = []) {
        self.init(
            title: ProductView.ViewModel.name(product: product, style: .profile),
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
        
        self.title = ProductView.ViewModel.name(product: product, style: .profile)
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
                title: "Активируйте",
                action: action
            )
        )
        self.alert = .init(alertViewModel)
    }
    
    func createPinCodeViewModel(displayNumber: String?) -> PinCodeViewModel {
        
        
        return .init(
            title: "Введите новый PIN-код для\nкарты *\(displayNumber ?? "")",
            pincodeLength: 4,
            confirmationPublisher: getPinConfirmationCodePublisher
        )
    }
}

//MARK: - Types

extension ProductProfileViewModel {
    
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
            case meToMe(PaymentsMeToMeViewModel)
            case meToMeLegacy(MeToMeViewModel)
            case printForm(PrintFormView.ViewModel)
            case placesMap(PlacesViewModel)
            case info(OperationDetailInfoViewModel)
        }
    }
    
    enum Link {
        
        case productInfo(InfoProductViewModel)
        case productStatement(ProductStatementViewModel)
        case meToMeExternal(MeToMeExternalViewModel)
        case myProducts(MyProductsViewModel)
        case paymentsTransfers(PaymentsTransfersViewModel)
        case changePin(PinCodeViewModel)
        case confirmCode
    }
    
    struct Sheet: Identifiable {
        
        let id = UUID()
        let type: Kind
        
        enum Kind {
            
            case printForm(PrintFormView.ViewModel)
            case placesMap(PlacesViewModel)
        }
    }
    
    struct FullCover: Identifiable {
        
        let id = UUID()
        let type: Kind
        
        enum Kind {
            case successMeToMe(PaymentsSuccessViewModel)
        }
    }
    
    struct ZeroAccount: Identifiable {
        
        let id = UUID()
        let viewModel: PaymentsSuccessViewModel
    
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
    
        struct ProductProfile: Action {
            
            let productId: ProductData.ID
        }
        
        struct OpenDeposit: Action {}
    }
    
    struct TransferButtonDidTapped: Action {}
}

extension ProductProfileViewModel {
    
    private func blockCard(with productData: ProductData?) {
        
        guard let productData = productData else {
            return
        }
        
        alert = alertBlockedCard(with: productData)
    }
    
    private func unblockCard(with productData: ProductData?) {
        
        blockCard(with: productData)
    }
    
    func handleCardType(
        _ type: ProductProfileOptionsPannelView.ViewModel.ButtonType.Card,
        _ productCard: ProductCardData
    ) {
        
        switch type {
            
        case .block:
            self.action.send(ProductProfileViewModelAction.Product.Block(productId: productCard.id))
            
        case .unblock:
            self.action.send(ProductProfileViewModelAction.Product.Unblock(productId: productCard.id))
            
        case .changePin:
            
            self.certificateClient.checkCertificate { [weak self] result in
                
                guard let self else { return }
                
                handleCheckCertificateResult(result, displayNumber: productCard.displayNumber)
            }
        }
    }
    
    func handleCheckCertificateResult(
        _ result: Result<Void, PinError>,
        displayNumber: String?
    ) {
        switch result {
            
        case let .failure(pinError):
            handlePinError(pinError)
            
        case .success:
            link = .changePin(createPinCodeViewModel(displayNumber: displayNumber))
        }
    }
    
    func handlePinError(_ pinError: (PinError)) {
        
        switch pinError {
            
        case .certificate:
            // TODO: extract
            let action: () -> Void = {
                
                self.certificateClient.activateCertificate { [weak self] result in
                    
                    guard let self else { return }
                    
                    switch result {
                        
                    case let .failure(error):
                        
                        makeAlert(error.localizedDescription)
                        
                    case .success:
                        
                        self.alert = nil
                        self.link = .confirmCode
                    }
                }
            }
            
            self.showActivateCertificateAlert(action: action)

        case .connectivity:
            makeAlert("Истеклo время\nожидания ответа")
        }
    }
}
