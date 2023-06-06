//
//  PaymentsTransfersViewModel.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 09.05.2022.
//

import SwiftUI
import Combine

class PaymentsTransfersViewModel: ObservableObject, Resetable {
    
    typealias TransfersSectionVM = PTSectionTransfersView.ViewModel
    typealias PaymentsSectionVM = PTSectionPaymentsView.ViewModel
    
    let action: PassthroughSubject<Action, Never> = .init()
    
    lazy var userAccountButton: MainViewModel.UserAccountButtonViewModel = .init(
        logo: .ic12LogoForaColor,
        name: "",
        avatar: nil,
        action: { [weak self] in
            self?.action.send(PaymentsTransfersViewModelAction
                .ButtonTapped.UserAccount())})
    
    @Published var sections: [PaymentsTransfersSectionViewModel]
    @Published var navButtonsRight: [NavigationBarButtonViewModel]
    @Published var bottomSheet: BottomSheet?
    @Published var sheet: Sheet?
    @Published var fullCover: FullCover?
    @Published var link: Link? { didSet { isLinkActive = link != nil; isTabBarHidden = link != nil } }
    @Published var isLinkActive: Bool = false
    @Published var isTabBarHidden: Bool = false
    @Published var fullScreenSheet: FullScreenSheet?
    @Published var alert: Alert.ViewModel?
    private let model: Model
    
    var rootActions: RootViewModel.RootActions?
    
    private var bindings = Set<AnyCancellable>()
    
    init(model: Model) {
        self.navButtonsRight = []
        self.sections = [
            PTSectionLatestPaymentsView.ViewModel(model: model),
            PTSectionTransfersView.ViewModel(),
            PTSectionPaymentsView.ViewModel()
        ]
        self.model = model
        self.navButtonsRight = createNavButtonsRight()
        
        bind()
        bindSections(sections)
        
        LoggerAgent.shared.log(level: .debug, category: .ui, message: "PaymentsTransfersViewModel initialized")
    }
    
    init(sections: [PaymentsTransfersSectionViewModel],
         model: Model,
         navButtonsRight: [NavigationBarButtonViewModel]) {
        
        self.sections = sections
        self.model = model
        self.navButtonsRight = navButtonsRight
        
        LoggerAgent.shared.log(level: .debug, category: .ui, message: "PaymentsTransfersViewModel initialized")
    }
    
    deinit {
        
        LoggerAgent.shared.log(level: .debug, category: .ui, message: "PaymentsTransfersViewModel deinitialized")
    }
    
    func reset() {
        
        bottomSheet = nil
        fullCover = nil
        sheet = nil
        link = nil
        fullScreenSheet = nil
        isTabBarHidden = false
    }
    
    private func bind() {
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case _ as PaymentsTransfersViewModelAction.ButtonTapped.UserAccount:
                    guard let clientInfo = model.clientInfo.value
                    else {return }
                    
                    link = .userAccount(
                        .init(model: model,
                              clientInfo: clientInfo,
                              dismissAction: {[weak self] in
                                  self?.action.send(PaymentsTransfersViewModelAction
                                    .Close.Link() )}))
                    
                case _ as PaymentsTransfersViewModelAction.ButtonTapped.Scanner:
                    
                    // на экране платежей верхний переход
                    let qrScannerModel = QRViewModel.init(closeAction: {
                        self.action.send(PaymentsTransfersViewModelAction.Close.FullScreenSheet())
                    })
                    
                    self.bind(qrScannerModel)
                    fullScreenSheet = .init(type: .qrScanner(qrScannerModel))
                    
                case _ as PaymentsTransfersViewModelAction.Close.BottomSheet:
                    bottomSheet = nil
                    
                case _ as PaymentsTransfersViewModelAction.Close.Sheet:
                    sheet = nil
                    
                case _ as PaymentsTransfersViewModelAction.Close.FullCover:
                    fullCover = nil
                    
                case _ as PaymentsTransfersViewModelAction.Close.Link:
                    link = nil
                    
                case _ as PaymentsTransfersViewModelAction.Close.FullScreenSheet:
                    fullScreenSheet = nil
                    
                    
                case _ as PaymentsTransfersViewModelAction.Close.DismissAll:
                    
                    withAnimation {
                        NotificationCenter.default.post(name: .dismissAllViewAndSwitchToMainTab, object: nil)
                    }
                    
                    
                case _ as PaymentsTransfersViewModelAction.ViewDidApear:
                    model.action.send(ModelAction.Contacts.PermissionStatus.Request())
                    isTabBarHidden = false
                
                case let payload as PaymentsTransfersViewModelAction.Show.Requisites:
                    self.action.send(PaymentsTransfersViewModelAction.Close.FullScreenSheet())
                    let paymentsViewModel = PaymentsViewModel(source: .requisites(qrCode: payload.qrCode), model: model, closeAction: {[weak self] in
                        
                        self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                    })
                    bind(paymentsViewModel)
                    
                    self.action.send(DelayWrappedAction(
                        delayMS: 700,
                        action: PaymentsTransfersViewModelAction.Show.Payment(viewModel: paymentsViewModel)))
                    
                default:
                    break
                }
            }.store(in: &bindings)
        
        action
            .compactMap({ $0 as? PaymentsTransfersViewModelAction.Show.Alert })
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                
                self.alert = .init(title: $0.title, message: $0.message, primary: .init(type: .default, title: "Ок", action: {}))
                
            }.store(in: &bindings)
        
        action
            .compactMap({ $0 as? PaymentsTransfersViewModelAction.Show.Payment })
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                
                self.link = .payments($0.viewModel)
                
            }.store(in: &bindings)
        
        action
            .compactMap({ $0 as? PaymentsTransfersViewModelAction.Show.Contacts })
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                
                let contactsViewModel = ContactsViewModel(model, mode: .fastPayments(.contacts))
                bind(contactsViewModel)
                
                sheet = .init(type: .fastPayment(contactsViewModel))
                
            }.store(in: &bindings)
        
        action
            .compactMap({ $0 as? PaymentsTransfersViewModelAction.Show.Countries })
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                
                let contactsViewModel = ContactsViewModel(model, mode: .abroad)
                bind(contactsViewModel)
                
                sheet = .init(type: .country(contactsViewModel))
                
            }.store(in: &bindings)
        
        action
            .compactMap({ $0 as? DelayWrappedAction })
            .flatMap({
                
                Just($0.action)
                    .delay(for: .milliseconds($0.delayMS), scheduler: DispatchQueue.main)

            })
            .sink(receiveValue: { [weak self] in
                
                self?.action.send($0)
                
            }).store(in: &bindings)
        
        model.clientInfo
            .combineLatest(model.clientPhoto, model.clientName)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] clientData in
                
                userAccountButton.update(clientInfo: clientData.0,
                                         clientPhoto: clientData.1,
                                         clientName: clientData.2)
            }.store(in: &bindings)
    }
    
    private func bindSections(_ sections: [PaymentsTransfersSectionViewModel]) {
        for section in sections {
            
            section.action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                        
                        //LatestPayments Section Buttons
                    case let payload as LatestPaymentsViewModelAction.ButtonTapped.LatestPayment:
                        handle(latestPayment: payload.latestPayment)
                        
                        //LatestPayment Section TemplateButton
                    case _ as LatestPaymentsViewModelAction.ButtonTapped.Templates:
                        let viewModel = TemplatesListViewModel(model, dismissAction: { [weak self] in self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                        })
                        link = .template(viewModel)
                        
                    case _ as LatestPaymentsViewModelAction.ButtonTapped.CurrencyWallet:
                        guard let firstCurrencyWalletData = model.currencyWalletList.value.first else {
                            return
                        }
                        
                        let currency = Currency(description: firstCurrencyWalletData.code)
                        
                        guard let walletViewModel = CurrencyWalletViewModel(currency: currency, currencyOperation: .buy, model: model, dismissAction: { [weak self] in
                            self?.action.send(PaymentsTransfersViewModelAction.Close.Link())}) else {
                            return
                        }
                        
                        model.action.send(ModelAction.Dictionary.UpdateCache.List(types: [.currencyWalletList, .currencyList, .countriesWithService]))
                        
                        link = .currencyWallet(walletViewModel)
                        
                        //Transfers Section
                    case let payload as PTSectionTransfersViewAction.ButtonTapped.Transfer:
                        
                        switch payload.type {
                        case .abroad:
                            self.action.send(PaymentsTransfersViewModelAction.Show.Countries())
                            
                        case .anotherCard:
                            model.action.send(ModelAction.ProductTemplate.List.Request())
                            let paymentsViewModel = PaymentsViewModel(model, service: .toAnotherCard, closeAction: { [weak self] in self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                            })
                            bind(paymentsViewModel)
                            
                            self.action.send(PaymentsTransfersViewModelAction.Show.Payment(viewModel: paymentsViewModel))
                    
                        case .betweenSelf:
                            
                            guard let viewModel = PaymentsMeToMeViewModel(model, mode: .demandDeposit) else {
                                return
                            }
                            
                            bind(viewModel)
                            
                            bottomSheet = .init(type: .meToMe(viewModel))
                            
                        case .requisites:
                            let paymentsViewModel = PaymentsViewModel(model, service: .requisites, closeAction: { [weak self] in
                                self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                            })
                            bind(paymentsViewModel)
                            
                            self.action.send(PaymentsTransfersViewModelAction.Show.Payment(viewModel: paymentsViewModel))
                            
                        case .byPhoneNumber:
                            self.action.send(PaymentsTransfersViewModelAction.Show.Contacts())
                        }
                        
                        //Payments Section
                    case let payload as PTSectionPaymentsViewAction.ButtonTapped.Payment:
                        
                        switch payload.type {
                        case .mobile:
                            let paymentsViewModel = PaymentsViewModel(model, service: .mobileConnection, closeAction: { [weak self] in
                                
                                self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                            })
                            bind(paymentsViewModel)
                            
                            self.action.send(PaymentsTransfersViewModelAction.Show.Payment(viewModel: paymentsViewModel))
                            
                        case .qrPayment:
                            
                            // на экране платежей нижний переход
                            let qrScannerModel = QRViewModel(closeAction: {
                                self.action.send(PaymentsTransfersViewModelAction.Close.FullScreenSheet())
                            })
                            
                            self.bind(qrScannerModel)
                            fullScreenSheet = .init(type: .qrScanner(qrScannerModel))
                            
                        case .service, .internet:
                            
                            if let dictionaryAnywayOperators = model.dictionaryAnywayOperators() {
                                
                                guard let operatorValue = Payments.operatorByPaymentsType(payload.type) else {
                                    return
                                }
                                
                                let operators = dictionaryAnywayOperators.filter({$0.parentCode == operatorValue.rawValue}).sorted(by: {$0.name.lowercased() < $1.name.lowercased()}).sorted(by: {$0.name.caseInsensitiveCompare($1.name) == .orderedAscending})
                                
                                self.action.send(PaymentsTransfersViewModelAction.Close.FullScreenSheet())
                                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(700)) {
                                    
                                    let navigationBarViewModel = NavigationBarView.ViewModel(title: PaymentsServicesViewModel.allRegion,
                                                                                             titleButton: .init(icon: Image.ic24ChevronDown, action: { [weak self] in
                                        self?.model.action.send(PaymentsServicesViewModelWithNavBarAction.OpenCityView())}),
                                                                                             leftItems: [NavigationBarView.ViewModel.BackButtonItemViewModel(icon: .ic24ChevronLeft, action: { [weak self] in self?.link = nil })],
                                                                                             rightItems: [
                                                                                                NavigationBarView.ViewModel.ButtonItemViewModel(icon: .qr_Icon, action: {
                                                                                                    [weak self] in
                                                                                                        self?.link = nil
                                                                                                        self?.action.send(PaymentsTransfersViewModelAction.ButtonTapped.Scanner())
                                                                                                })
                                                                                             ]
                                    )
                                    let lastPaymentsKind: LatestPaymentData.Kind = .init(rawValue: payload.type.rawValue) ?? .unknown
                                    let latestPayments = PaymentsServicesLatestPaymentsSectionViewModel(model: self.model, including: [lastPaymentsKind])

                                    let operatorsViewModel = PaymentsServicesViewModel(searchBar: .init(textFieldPhoneNumberView: .init(style: .general, placeHolder: .text("Наименование или ИНН")), state: .idle),
                                                                                       navigationBar: navigationBarViewModel,
                                                                                       model: self.model,
                                                                                       latestPayments: latestPayments,
                                                                                       allOperators: operators,
                                                                                       addCompanyAction: { [weak self] in
                                        
                                        self?.link = nil
                                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                                            self?.rootActions?.switchTab(.chat)
                                        }
                                        
                                    }, requisitesAction: { [weak self] in
                                        
                                        self?.link = nil
                                        self?.action.send(PaymentsTransfersViewModelAction.Show.Requisites(qrCode: .init(original: "", rawData: [:])))
                                    })
                                    
                                    self.link = .paymentsServices(operatorsViewModel)
                                }
                            }
                            
                        case .transport:
                            let transportOperators = OperatorsViewModel(mode: .general, closeAction: { [weak self] in self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                            }, requisitsViewAction: { [weak self] in
                                
                                guard let self else { return }
                                
                                self.action.send(PaymentsTransfersViewModelAction.Close.Link())
                                let paymentsViewModel = PaymentsViewModel(model, service: .requisites, closeAction: {
                                    self.action.send(PaymentsTransfersViewModelAction.Close.Link())
                                })
                                self.bind(paymentsViewModel)
                                
                                self.action.send(DelayWrappedAction(
                                    delayMS: 800,
                                    action: PaymentsTransfersViewModelAction.Show.Payment(viewModel: paymentsViewModel))
                                )
                                
                            }, qrAction: { [weak self] in
                                
                                self?.link = nil
                                self?.action.send(PaymentsTransfersViewModelAction.ButtonTapped.Scanner())
                            })
                            link = .transportOperators(transportOperators)
                            InternetTVMainViewModel.filter = GlobalModule.PAYMENT_TRANSPORT
                            
                        case .taxAndStateService:
                            let paymentsViewModel = PaymentsViewModel(category: Payments.Category.taxes, model: model) { [weak self] in self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                            }
                            link = .init(.payments(paymentsViewModel))

                        case .socialAndGame: bottomSheet = .init(type: .exampleDetail(payload.type.rawValue)) //TODO:
                        case .security: bottomSheet = .init(type: .exampleDetail(payload.type.rawValue)) //TODO:
                        case .others: bottomSheet = .init(type: .exampleDetail(payload.type.rawValue)) //TODO:
                            
                        }
                    default:
                        break
                        
                    }
                    
                }.store(in: &bindings)
        }
    }
    
    private func bind(_ paymentsViewModel: PaymentsViewModel) {
    
        paymentsViewModel.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
            
                switch action {
                case _ as PaymentsViewModelAction.ScanQrCode:
                    
                    self.link = nil
                    
                    let qrScannerModel = QRViewModel.init(closeAction: {
                        self.action.send(PaymentsTransfersViewModelAction.Close.FullScreenSheet())
                    })
                    
                    self.bind(qrScannerModel)
                    fullScreenSheet = .init(type: .qrScanner(qrScannerModel))
                    
                case let payload as PaymentsViewModelAction.ContactAbroad:
                    let paymentsViewModel = PaymentsViewModel(source: payload.source, model: model) { [weak self] in
                        
                        self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                    }
                    
                    self.action.send(DelayWrappedAction(
                        delayMS: 700,
                        action: PaymentsTransfersViewModelAction.Show.Payment(viewModel: paymentsViewModel))
                    )
                    
                default: break
                }
                
            }.store(in: &bindings)
    }
    
    private func bind(_ viewModel: PaymentsMeToMeViewModel) {
        
        viewModel.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as PaymentsMeToMeAction.Response.Success:
                    
                    guard let productIdFrom = viewModel.swapViewModel.productIdFrom,
                          let productIdTo = viewModel.swapViewModel.productIdTo else {
                        return
                    }
                    
                    model.action.send(ModelAction.Products.Update.Fast.Single.Request(productId: productIdFrom))
                    model.action.send(ModelAction.Products.Update.Fast.Single.Request(productId: productIdTo))
                    
                    bind(payload.viewModel)
                    fullCover = .init(type: .successMeToMe(payload.viewModel))
                    
                case _ as PaymentsMeToMeAction.Response.Failed:
                    
                    makeAlert("Перевод выполнен")
                    self.action.send(PaymentsTransfersViewModelAction.Close.BottomSheet())
               
                case _ as PaymentsMeToMeAction.Close.BottomSheet:
                    
                    self.action.send(PaymentsTransfersViewModelAction.Close.BottomSheet())

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
    
    private func bind(_ viewModel: PaymentsSuccessViewModel) {
        
        viewModel.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case _ as PaymentsSuccessAction.Button.Close:
                    model.action.send(ModelAction.Products.Update.ForProductType(productType: .deposit))

                    self.action.send(PaymentsTransfersViewModelAction.Close.FullCover())
                    self.action.send(PaymentsTransfersViewModelAction.Close.DismissAll())
                    
                    self.rootActions?.switchTab(.main)
                    
                case _ as PaymentsSuccessAction.Button.Repeat:
                    
                    self.action.send(PaymentsTransfersViewModelAction.Close.FullCover())
                    self.rootActions?.switchTab(.payments)
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
    }
    
    private func bind(_ viewModel: ContactsViewModel) {
        
        viewModel.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as ContactsViewModelAction.PaymentRequested:
                    
                    self.action.send(PaymentsTransfersViewModelAction.Close.Sheet())
                    
                    switch payload.source {
                    case let .latestPayment(latestPaymentId):
                        guard let latestPayment = model.latestPayments.value.first(where: { $0.id == latestPaymentId }) else {
                            return
                        }
                        handle(latestPayment: latestPayment)
                        
                    default:
                        let paymentsViewModel = PaymentsViewModel(source: payload.source, model: model) { [weak self] in
                            
                            guard let self else { return }
                            
                            self.action.send(PaymentsTransfersViewModelAction.Close.Link())
                            
                            switch payload.source {
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
                    
                case let payload as ContactsSectionViewModelAction.Countries.ItemDidTapped:
                    let paymentsViewModel = PaymentsViewModel(source: payload.source, model: model) { [weak self] in
                        
                        guard let self else { return }
                        
                        self.action.send(PaymentsTransfersViewModelAction.Close.Link())
                        
                        switch payload.source {
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

                default:
                    break
                }
                
            }.store(in: &bindings)
    }
    
    func bind(_ qrViewModel: QRViewModel) {
        
        qrViewModel.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as QRViewModelAction.Result:
                    
                    switch payload.result {
                    case .qrCode(let qr):
                        
                        if let qrMapping = model.qrMapping.value {
                            
                            if let operatorsFromQr = model.dictionaryAnywayOperators(with: qr, mapping: qrMapping)  {
                                let validQrOperators = model.dictionaryQRAnewayOperator()
                                let operators = operatorsFromQr.filter{ validQrOperators.contains($0) && !$0.parameterList.isEmpty }
                                
                                guard operators.count > 0 else {
                                
                                    self.action.send(PaymentsTransfersViewModelAction.Close.FullScreenSheet())
                                    self.action.send(PaymentsTransfersViewModelAction.Show.Requisites(qrCode: qr))
                                    return
                                }
                                
                                if operators.count == 1 {
                                    self.action.send(PaymentsTransfersViewModelAction.Close.FullScreenSheet())
                                    
                                    if let operatorValue = operators.first, Payments.paymentsServicesOperators.map(\.rawValue).contains(operatorValue.parentCode) {
                                        Task { [weak self] in
                                            guard let self = self else { return }
                                            let puref = operatorValue.code
                                            let additionalList = model.additionalList(for: operatorValue, qrCode: qr)
                                            let amount: Double = qr.rawData["sum"]?.toDouble() ?? 0
                                            let paymentsViewModel = PaymentsViewModel(
                                                source: .servicePayment(puref: puref, additionalList: additionalList, amount: amount/100),
                                                model: model,
                                                closeAction: { [weak self] in
                                                    self?.model.action.send(PaymentsTransfersViewModelAction.Close.Link())
                                                    
                                                })
                                            self.bind(paymentsViewModel)

                                            await MainActor.run { [weak self] in
                                                self?.link = .init(.payments(paymentsViewModel))
                                            }
                                        }
                                    }
                                    else {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(700)) { [self] in
                                            
                                            let viewModel = InternetTVDetailsViewModel(model: model, qrCode: qr, mapping: qrMapping)
                                            
                                            self.link = .operatorView(viewModel)
                                        }
                                        
                                    }
                                    
                                } else {
                                    
                                    self.action.send(PaymentsTransfersViewModelAction.Close.FullScreenSheet())
                                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(700)) {
                                        
                                        let navigationBarViewModel = NavigationBarView.ViewModel(title: "Все регионы", titleButton: .init(icon: Image.ic24ChevronDown, action: { [weak self] in
                                            self?.model.action.send(QRSearchOperatorViewModelAction.OpenCityView())
                                        }), leftItems: [NavigationBarView.ViewModel.BackButtonItemViewModel(icon: .ic24ChevronLeft, action: { [weak self] in self?.link = nil })])
                                        
                                        let operatorsViewModel = QRSearchOperatorViewModel(searchBar: .init(textFieldPhoneNumberView: .init(style: .general, placeHolder: .text("Название или ИНН")), state: .idle, icon: Image.ic24Search),
                                                                                           navigationBar: navigationBarViewModel, model: self.model,
                                                                                           operators: operators, addCompanyAction: { [weak self] in
                                            
                                            self?.link = nil
                                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                                                self?.rootActions?.switchTab(.chat)
                                            }
                                            
                                        }, requisitesAction: { [weak self] in
                                            
                                            self?.link = nil
                                            self?.action.send(PaymentsTransfersViewModelAction.Show.Requisites(qrCode: qr))


                                        }, qrCode: qr)
                                        
                                        self.link = .searchOperators(operatorsViewModel)
                                    }
                                }
                                
                            } else {
                                
                                self.action.send(PaymentsTransfersViewModelAction.Close.FullScreenSheet())
                                self.action.send(PaymentsTransfersViewModelAction.Show.Requisites(qrCode: qr))
                            }
                            
                        } else {
                            
                            self.action.send(PaymentsTransfersViewModelAction.Close.FullScreenSheet())
                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(700)) {
                                
                                let failedView = QRFailedViewModel(model: self.model, addCompanyAction: { [weak self] in
                                    
                                    self?.link = nil
                                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                                        self?.rootActions?.switchTab(.chat)
                                    }
                                    
                                }, requisitsAction: { [weak self] in
                                    
                                    self?.fullScreenSheet = nil
                                    self?.action.send(PaymentsTransfersViewModelAction.Show.Requisites(qrCode: qr))

                                })
                                self.link = .failedView(failedView)
                            }
                        }
                        
                    case .c2bURL(let c2bURL):
                        
                        // show c2b payment after delay required to finish qr scanner close animation
                        self.action.send(PaymentsTransfersViewModelAction.Close.FullScreenSheet())
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(700)) {
                            
                            let c2bViewModel = C2BViewModel(urlString: c2bURL.absoluteString, closeAction: { [weak self] in
                                self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                            })
                            
                            self.link = .c2b(c2bViewModel)
                        }
                        
                    case .c2bSubscribeURL(let url):
                        self.action.send(PaymentsTransfersViewModelAction.Close.FullScreenSheet())
                        let paymentsViewModel = PaymentsViewModel(source: .c2bSubscribe(url), model: model, closeAction: {[weak self] in
                            
                            self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                        })
                        bind(paymentsViewModel)
                        
                        self.action.send(DelayWrappedAction(
                            delayMS: 700,
                            action: PaymentsTransfersViewModelAction.Show.Payment(viewModel: paymentsViewModel))
                        )
 
                    case .url(_):
                        
                        self.action.send(PaymentsTransfersViewModelAction.Close.FullScreenSheet())
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(700)) {
                            
                            let failedView = QRFailedViewModel(model: self.model, addCompanyAction: { [weak self] in
                                
                                self?.link = nil
                                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                                    self?.rootActions?.switchTab(.chat)
                                }
                                
                            }, requisitsAction: { [weak self] in
                                
                                guard let self else { return }
                                
                                self.action.send(PaymentsTransfersViewModelAction.Close.FullScreenSheet())
                                let paymentsViewModel = PaymentsViewModel(model, service: .requisites, closeAction: {[weak self] in
                                    self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                                })
                                self.bind(paymentsViewModel)
                                
                                self.action.send(DelayWrappedAction(
                                    delayMS: 800,
                                    action: PaymentsTransfersViewModelAction.Show.Payment(viewModel: paymentsViewModel))
                                )
                            })
                            self.link = .failedView(failedView)
                        }
                        
                    case .unknown:
                        
                        self.action.send(PaymentsTransfersViewModelAction.Close.FullScreenSheet())
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(700)) {
                            
                            let failedView = QRFailedViewModel(model: self.model, addCompanyAction: { [weak self] in
                                
                                self?.link = nil
                                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                                    self?.rootActions?.switchTab(.chat)
                                }
                                
                            }, requisitsAction: { [weak self] in
                                
                                guard let self else { return }
                                
                                self.action.send(PaymentsTransfersViewModelAction.Close.FullScreenSheet())
                                let paymentsViewModel = PaymentsViewModel(model, service: .requisites, closeAction: {
                                    self.action.send(PaymentsTransfersViewModelAction.Close.Link())
                                })
                                self.bind(paymentsViewModel)
                                
                                self.action.send(DelayWrappedAction(
                                    delayMS: 800,
                                    action: PaymentsTransfersViewModelAction.Show.Payment(viewModel: paymentsViewModel))
                                )

                            })
                            self.link = .failedView(failedView)
                        }
                    }
                    
                default:
                    break
                }
            }.store(in: &bindings)
    }

    
    private func makeAlert(_ message: String) {
        
        let alertViewModel = Alert.ViewModel(title: "Ошибка", message: message, primary: .init(type: .default, title: "ОК") { [weak self] in
            self?.action.send(ProductProfileViewModelAction.Close.Alert())
        })
        
        alert = .init(alertViewModel)
    }
    
    private func createNavButtonsRight() -> [NavigationBarButtonViewModel] {
        
        [.init(icon: .ic24BarcodeScanner2,
               action: { [weak self] in
            self?.action.send(PaymentsTransfersViewModelAction
                .ButtonTapped.Scanner())})
        ]
    }
}

//MARK: - Helpers

extension PaymentsTransfersViewModel {
    
    func handle(latestPayment: LatestPaymentData) {
        
        switch (latestPayment.type, latestPayment) {
        //TODO: move case transport after refactoring
        case (.transport, let paymentData as PaymentServiceData):
            let operatorsViewModel = OperatorsViewModel(mode: .general, paymentServiceData: paymentData, model: model, closeAction: { [weak self] in
                self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
            }, requisitsViewAction: {}, qrAction: { [weak self] in
                
                self?.link = nil
            })
            link = .transport(operatorsViewModel)
            
        case (.internet, let paymentData),
            (.service, let paymentData),
            (.mobile, let paymentData),
            (.outside, let paymentData),
            (.phone, let paymentData):
            
                let paymentsViewModel = PaymentsViewModel(source: .latestPayment(paymentData.id),
                                                          model: model) { [weak self] in
                    
                    guard let self else { return }
                    
                    self.action.send(PaymentsTransfersViewModelAction.Close.Link())
                }
                
                bind(paymentsViewModel)
                
                self.action.send(DelayWrappedAction(
                    delayMS: 300,
                    action: PaymentsTransfersViewModelAction.Show.Payment(viewModel: paymentsViewModel))
                )

        case (.taxAndStateService, let paymentData as PaymentServiceData):
            bottomSheet = .init(type: .exampleDetail(paymentData.type.rawValue)) //TODO:
            
        default: //error matching
            bottomSheet = .init(type: .exampleDetail(latestPayment.type.rawValue)) //TODO:
        }
    }
}

//MARK: - Types

extension PaymentsTransfersViewModel {
    
    struct BottomSheet: BottomSheetCustomizable {
        
        let id = UUID()
        let type: Kind
        
        let isUserInteractionEnabled: CurrentValueSubject<Bool, Never> = .init(true)
        
        var keyboardOfssetMultiplier: CGFloat {
            
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
    
    enum Link {
        
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
    }
    
    struct FullScreenSheet: Identifiable, Equatable {
        
        let id = UUID()
        let type: Kind
        
        enum Kind {
            
            case qrScanner(QRViewModel)
        }
        
        static func == (lhs: PaymentsTransfersViewModel.FullScreenSheet, rhs: PaymentsTransfersViewModel.FullScreenSheet) -> Bool {
            lhs.id == rhs.id
        }
    }
    
}

//MARK: - Action

enum PaymentsTransfersViewModelAction {
    
    enum ButtonTapped {
        
        struct UserAccount: Action {}
        
        struct Scanner: Action {}
    }
    
    enum Close {
        
        struct BottomSheet: Action {}
        
        struct Sheet: Action {}
        
        struct FullCover: Action {}
        
        struct Link: Action {}
        
        struct DismissAll: Action {}
        
        struct FullScreenSheet: Action {}
    }
    
    struct OpenQr: Action {}
    
    enum Show {
        
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
    }
    
    struct ViewDidApear: Action {}
}
