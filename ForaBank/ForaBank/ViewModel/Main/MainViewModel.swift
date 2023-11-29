//
//  MainViewModel.swift
//  ForaBank
//
//  Created by Max Gribov on 24.02.2022.
//

import Foundation
import Combine
import SwiftUI
import LandingUIComponent
import PaymentSticker

class MainViewModel: ObservableObject, Resetable {
    
    typealias MakeProductProfileViewModel = (ProductData, String, @escaping () -> Void) -> ProductProfileViewModel?
    
    let action: PassthroughSubject<Action, Never> = .init()
    
    lazy var userAccountButton: UserAccountButtonViewModel = .init(logo: .ic12LogoForaColor, name: "", avatar: nil, action: { [weak self] in self?.action.send(MainViewModelAction.ButtonTapped.UserAccount())})
    @Published var navButtonsRight: [NavigationBarButtonViewModel]
    @Published var sections: [MainSectionViewModel]
    @Published var productProfile: ProductProfileViewModel?
    
    @Published var route: Route?
    
    var rootActions: RootViewModel.RootActions?
    
    private let model: Model
    private let makeProductProfileViewModel: MakeProductProfileViewModel
    private let onRegister: () -> Void
    private let factory: ModelAuthLoginViewModelFactory
    private var bindings = Set<AnyCancellable>()
    
    init(
        _ model: Model,
        makeProductProfileViewModel: @escaping MakeProductProfileViewModel,
        onRegister: @escaping () -> Void
    ) {
        self.model = model
        self.navButtonsRight = []
        self.sections = [
            MainSectionProductsView.ViewModel(model, stickerViewModel: nil),
            MainSectionFastOperationView.ViewModel(),
            MainSectionPromoView.ViewModel(model),
            MainSectionCurrencyMetallView.ViewModel(model),
            MainSectionOpenProductView.ViewModel(model),
            MainSectionAtmView.ViewModel.initial
        ]
        
        self.factory = ModelAuthLoginViewModelFactory(model: model, rootActions: .emptyMock)
        self.makeProductProfileViewModel = makeProductProfileViewModel
        self.onRegister = onRegister
        self.navButtonsRight = createNavButtonsRight()
        
        bind()
        update(sections, with: model.settingsMainSections)
        bind(sections)
    }
    
    private static func getSections(
        _ model: Model,
        stickerViewModel: ProductCarouselView.StickerViewModel? = nil
    ) -> [MainSectionViewModel] {
        
        return [
            MainSectionProductsView.ViewModel(
                model,
                stickerViewModel: stickerViewModel
            ),
            MainSectionFastOperationView.ViewModel(),
            MainSectionPromoView.ViewModel(model),
            MainSectionCurrencyMetallView.ViewModel(model),
            MainSectionOpenProductView.ViewModel(model),
            MainSectionAtmView.ViewModel.initial
        ]
    }
    
    private func makeStickerViewModel(_ model: Model) -> ProductCarouselView.StickerViewModel? {
        
        return ProductCarouselView.ViewModel.makeStickerViewModel(model) {
            self.handleLandingAction(.sticker)
        } hide: { [self] in
            model.settingsAgent.saveShowStickerSetting(shouldShow: false)
            self.sections = MainViewModel.getSections(model)
            self.bind(sections)
        }
    }
    
    func reset() {
        
        route = nil
        
        for section in sections {
            
            switch section {
            case let productsSection as MainSectionProductsView.ViewModel:
                productsSection.action.send(MainSectionViewModelAction.Products.ResetScroll())
            default:
                continue
            }
        }
    }
}

private extension MainViewModel {
    
    func bind() {
        
        model.images
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] images in
                
                if let products = self.sections.first(where: { $0.type == .products }) as? MainSectionProductsView.ViewModel,
                   products.productCarouselViewModel.stickerViewModel == nil {
                    
                    self.sections = Self.getSections(model, stickerViewModel: makeStickerViewModel(model))
                    bind(sections)
                }
            }
            .store(in: &bindings)
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as MainViewModelAction.Show.ProductProfile:
                    guard let product = model.product(productId: payload.productId),
                          let productProfileViewModel = makeProductProfileViewModel(
                            product,
                            "\(type(of: self))",
                            { [weak self] in self?.route = nil })
                    else { return }
                    
                    productProfileViewModel.rootActions = rootActions
                    bind(productProfileViewModel)
                    route = .link(.productProfile(productProfileViewModel))
                    
                case _ as MainViewModelAction.ButtonTapped.UserAccount:
                    guard let clientInfo = model.clientInfo.value else {
                        return
                    }
                    
                    model.action.send(ModelAction.C2B.GetC2BSubscription.Request())
                    
                    // TODO: replace with injected factory
                    route = .link(.userAccount(.init(
                        model: model,
                        clientInfo: clientInfo,
                        dismissAction: { [weak self] in
                            
                            self?.action.send(MainViewModelAction.Close.Link())
                        }
                    )))
                    
                case _ as MainViewModelAction.ButtonTapped.Messages:
                    let messagesHistoryViewModel: MessagesHistoryViewModel = .init(model: model, closeAction: {[weak self] in self?.action.send(MainViewModelAction.Close.Link())})
                    route = .link(.messages(messagesHistoryViewModel))
                    
                case _ as MainViewModelAction.PullToRefresh:
                    model.action.send(ModelAction.Products.Update.Total.All())
                    model.action.send(ModelAction.Dictionary.UpdateCache.List(types: [.currencyWalletList, .currencyList, .bannerCatalogList]))
                    
                case _ as MainViewModelAction.Close.Link:
                    route = nil
                    
                case _ as MainViewModelAction.Close.Sheet:
                    self.route = nil
                    
                case _ as MainViewModelAction.Close.FullScreenSheet:
                    self.route = nil
                    
                case _ as PaymentsViewModelAction.ScanQrCode:
                    let qrScannerModel = QRViewModel.init(closeAction: { [weak self] in
                        self?.action.send(MainViewModelAction.Close.FullScreenSheet())
                    })
                    
                    bind(qrScannerModel)
                    route = .fullScreenSheet(.init(type: .qrScanner(qrScannerModel)))
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
        
        action
            .compactMap({ $0 as? MainViewModelAction.Show.Requisites })
            .map(\.qrCode)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [unowned self] qrCode in
                
                action.send(MainViewModelAction.Close.FullScreenSheet())
                let paymentsViewModel = PaymentsViewModel(source: .requisites(qrCode: qrCode), model: model, closeAction: {[weak self] in self?.action.send(MainViewModelAction.Close.Link() )})
                bind(paymentsViewModel)
                
                action.send(DelayWrappedAction(
                    delayMS: 700,
                    action: MainViewModelAction.Show.Payments(paymentsViewModel: paymentsViewModel))
                )
                
            }).store(in: &bindings)
        
        action
            .compactMap({ $0 as? MainViewModelAction.Show.Payments })
            .map(\.paymentsViewModel)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [unowned self] paymentsViewModel in
                
                route = .link(.payments(paymentsViewModel))
                
            }).store(in: &bindings)
        
        action
            .compactMap({ $0 as? MainViewModelAction.Show.Contacts })
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [unowned self] _ in
                
                let contactsViewModel = model.makeContactsViewModel(forMode: .fastPayments(.contacts))
                bind(contactsViewModel)
                
                route = .sheet(.init(type: .byPhone(contactsViewModel)))
                
            }).store(in: &bindings)
        
        action
            .compactMap({ $0 as? MainViewModelAction.Show.Countries })
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [unowned self] _ in
                
                let contactsViewModel = model.makeContactsViewModel(forMode: .abroad)
                bind(contactsViewModel)
                
                route = .sheet(.init(type: .byPhone(contactsViewModel)))
                
            }).store(in: &bindings)
        
        action
            .compactMap({ $0 as? DelayWrappedAction })
            .flatMap({
                
                Just($0.action)
                    .delay(for: .milliseconds($0.delayMS), scheduler: DispatchQueue.main)
                
            })
            .sink(receiveValue: { [weak self] in
                
                self?.action.send($0)
                
            }).store(in: &bindings)
        
        model.products
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] products in
                
                guard let deposits = products[.deposit] else { return }
                
                for deposit in deposits {
                    
                    if let deposit = deposit as? ProductDepositData {
                        
                        guard !self.model.depositsCloseNotified.contains(.init(depositId: deposit.depositId)), deposit.endDateNf else {
                            continue
                        }
                        
                        self.route = .alert(.init(title: "Срок действия вклада истек", message: "Переведите деньги со вклада на свою карту/счет в любое время", primary: .init(type: .default, title: "Отмена", action: {}), secondary: .init(type: .default, title: "Ok", action: {
                            
                            self.action.send(MainViewModelAction.Show.ProductProfile(productId: deposit.id))
                        })))
                        
                        self.model.action.send(ModelAction.Deposits.CloseNotified(productId: deposit.id))
                        
                        return
                    }
                }
            }.store(in: &bindings)
        
        model.clientInfo
            .combineLatest(model.clientPhoto, model.clientName)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] clientData in
                
                userAccountButton.update(clientInfo: clientData.0, clientPhoto: clientData.1, clientName: clientData.2)
                
            }.store(in: &bindings)
    }
    
    func bind(_ sections: [MainSectionViewModel]) {
        
        for section in sections {
            
            switch section {
            case let openProductSection as MainSectionOpenProductView.ViewModel:
                openProductSection.action
                    .receive(on: DispatchQueue.main)
                    .sink { [unowned self] action in
                        
                        switch action {
                        case let payload as MainSectionViewModelAction.OpenProduct.ButtonTapped:
                            
                            switch payload.productType {
                            case .account:
                                
                                let accountProductsList = model.accountProductsList.value
                                
                                guard let openAccountViewModel: OpenAccountViewModel = .init(model, products: accountProductsList) else {
                                    return
                                }
                                
                                route = .bottomSheet(.init(type: .openAccount(openAccountViewModel)))
                                
                            case .deposit:
                                self.openDeposit()
                                
                            case .card:
                                
                                let authProductsViewModel = AuthProductsViewModel(
                                    self.model,
                                    products: self.model.catalogProducts.value,
                                    dismissAction: { [weak self] in
                                        self?.action.send(MainViewModelAction.Close.Link())
                                    })
                                
                                route = .link( .openCard(authProductsViewModel))
                                
                            default:
                                //MARK: Action for Sticker Product
                                
                                handleLandingAction(.sticker)
                            }
                            
                        default:
                            break
                        }
                        
                    }.store(in: &bindings)
                
            case let fastPayment as MainSectionFastOperationView.ViewModel:
                fastPayment.action
                    .receive(on: DispatchQueue.main)
                    .sink { [unowned self] action in
                        
                        switch action {
                        case let payload as MainSectionViewModelAction.FastPayment.ButtonTapped:
                            switch payload.operationType {
                            case .templates:
                                
                                let templatesListViewModel = TemplatesListViewModel(
                                    model, dismissAction: { [weak self] in self?.action.send(MainViewModelAction.Close.Link()) })
                                bind(templatesListViewModel)
                                route = .link(.templates(templatesListViewModel))
                                
                            case .byPhone:
                                self.action.send(MainViewModelAction.Show.Contacts())
                                
                            case .byQr:
                                
                                let qrScannerModel = QRViewModel.init(closeAction: { [weak self] in
                                    self?.action.send(MainViewModelAction.Close.FullScreenSheet())
                                })
                                
                                bind(qrScannerModel)
                                route = .fullScreenSheet(.init(type: .qrScanner(qrScannerModel)))
                            }
                            
                        default:
                            break
                        }
                        
                    }.store(in: &bindings)
                
                // Promo section
            case let promo as MainSectionPromoView.ViewModel:
                promo.action
                    .receive(on: DispatchQueue.main)
                    .sink { [unowned self] action in
                        
                        switch action {
                        case let payload as MainSectionViewModelAction.PromoAction.ButtonTapped:
                            switch payload.actionData {
                            case let payload as BannerActionDepositOpen:
                                guard let depositId = Int(payload.depositProductId),
                                      let openDepositViewModel: OpenDepositDetailViewModel = .init(depositId: depositId, model: model) else {
                                    
                                    return
                                }
                                route = .link( .openDeposit(openDepositViewModel))
                                
                            case _ as BannerActionDepositsList:
                                route = .link(.openDepositsList(.init(model, catalogType: .deposit, dismissAction: { [weak self] in
                                    self?.action.send(MainViewModelAction.Close.Link())
                                })))
                                
                            case let payload as BannerActionMigTransfer:
                                let paymentsViewModel = PaymentsViewModel(source: .direct(phone: nil, countryId: payload.countryId), model: model) { [weak self] in
                                    
                                    self?.action.send(PaymentsTransfersViewModelAction.Close.Link())
                                }
                                bind(paymentsViewModel)
                                
                                self.action.send(MainViewModelAction.Show.Payments(paymentsViewModel: paymentsViewModel))
                                
                                
                            case let payload as BannerActionContactTransfer:
                                let paymentsViewModel = PaymentsViewModel(source: .direct(phone: nil, countryId: payload.countryId), model: model) { [weak self] in
                                    
                                    guard let self else { return }
                                    
                                    self.action.send(PaymentsTransfersViewModelAction.Close.Link())
                                    self.action.send(DelayWrappedAction(
                                        delayMS: 300,
                                        action: MainViewModelAction.Show.Countries())
                                    )
                                }
                                bind(paymentsViewModel)
                                
                                self.action.send(DelayWrappedAction(
                                    delayMS: 300,
                                    action: MainViewModelAction.Show.Payments(paymentsViewModel: paymentsViewModel))
                                )
                                
                            default:
                                handleLandingAction(.sticker)
                            }
                        default:
                            break
                        }
                        
                    }.store(in: &bindings)
                
            default: break
            }
            
            section.action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                        // products section
                    case let payload as MainSectionViewModelAction.Products.ProductDidTapped:
                        self.action.send(MainViewModelAction.Show.ProductProfile(productId: payload.productId))
                        
                    case _ as MainSectionViewModelAction.Products.StickerDidTapped:
                        handleLandingAction(.sticker)
                        
                    case _ as MainSectionViewModelAction.Products.MoreButtonTapped:
                        let myProductsViewModel = MyProductsViewModel(
                            model,
                            makeProductProfileViewModel: makeProductProfileViewModel
                        )
                        myProductsViewModel.rootActions = rootActions
                        route = .link(.myProducts(myProductsViewModel))
                        
                        // CurrencyMetall section
                        
                    case let payload as MainSectionViewModelAction.CurrencyMetall.DidTapped.Item:
                        
                        guard let walletViewModel = CurrencyWalletViewModel(currency: payload.code, currencyOperation: .buy, model: model, dismissAction: { [weak self] in
                            self?.action.send(MainViewModelAction.Close.Link())}) else {
                            return
                        }
                        
                        model.action.send(ModelAction.Dictionary.UpdateCache.List(types: [.currencyWalletList, .currencyList]))
                        model.action.send(ModelAction.Account.ProductList.Request())
                        route = .link(.currencyWallet(walletViewModel))
                        
                    case let payload as MainSectionViewModelAction.CurrencyMetall.DidTapped.Buy:
                        
                        guard let walletViewModel = CurrencyWalletViewModel(currency: payload.code, currencyOperation: .buy, model: model, dismissAction: { [weak self] in
                            self?.action.send(MainViewModelAction.Close.Link())}) else {
                            return
                        }
                        
                        model.action.send(ModelAction.Dictionary.UpdateCache.List(types: [.currencyWalletList, .currencyList]))
                        model.action.send(ModelAction.Account.ProductList.Request())
                        route = .link(.currencyWallet(walletViewModel))
                        
                    case let payload as MainSectionViewModelAction.CurrencyMetall.DidTapped.Sell:
                        
                        guard let walletViewModel = CurrencyWalletViewModel(currency: payload.code, currencyOperation: .sell, model: model, dismissAction: { [weak self] in
                            self?.action.send(MainViewModelAction.Close.Link())}) else {
                            return
                        }
                        
                        model.action.send(ModelAction.Dictionary.UpdateCache.List(types: [.currencyWalletList, .currencyList]))
                        model.action.send(ModelAction.Account.ProductList.Request())
                        route = .link(.currencyWallet(walletViewModel))
                        
                        // atm section
                    case _ as MainSectionViewModelAction.Atm.ButtonTapped:
                        guard let placesViewModel = PlacesViewModel(model) else {
                            return
                        }
                        route = .sheet(.init(type: .places(placesViewModel)))
                        
                    default:
                        break
                        
                    }
                }.store(in: &bindings)
            
            if let collapsableSection = section as? MainSectionCollapsableViewModel {
                
                collapsableSection.$isCollapsed
                    .dropFirst()
                    .receive(on: DispatchQueue.main)
                    .sink { [unowned self] isCollapsed in
                        
                        var settings = model.settingsMainSections
                        settings.update(sectionType: collapsableSection.type, isCollapsed: isCollapsed)
                        model.settingsMainSectionsUpdate(settings)
                        
                    }.store(in: &bindings)
            }
        }
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
                                    
                                    self.route = nil
                                    self.action.send(MainViewModelAction.Show.Requisites(qrCode: qr))
                                    return
                                }
                                
                                if operators.count == 1 {
                                    self.action.send(MainViewModelAction.Close.FullScreenSheet())
                                    if let operatorValue = operators.first, Payments.paymentsServicesOperators.map(\.rawValue).contains(operatorValue.parentCode) {
                                        
                                        Task { [weak self] in
                                            
                                            guard let self = self else { return }
                                            let puref = operatorValue.code
                                            let additionalList = self.model.additionalList(for: operatorValue, qrCode: qr)
                                            let amount: Double = qr.rawData["sum"]?.toDouble() ?? 0
                                            let paymentsViewModel = PaymentsViewModel(
                                                source: .servicePayment(
                                                    puref: puref, 
                                                    additionalList: additionalList,
                                                    amount: amount/100
                                                ),
                                                model: self.model,
                                                closeAction: {
                                                    
                                                    self.model.action.send(PaymentsTransfersViewModelAction.Close.Link())
                                                })
                                            self.bind(paymentsViewModel)
                                            
                                            await MainActor.run {
                                                self.route = .link( .payments(paymentsViewModel))
                                            }
                                        }
                                    }
                                    else {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(700)) { [self] in
                                            
                                            let viewModel = InternetTVDetailsViewModel(model: model, qrCode: qr, mapping: qrMapping)
                                            
                                            route = .link( .operatorView(viewModel))
                                        }
                                    }
                                } else {
                                    
                                    self.action.send(MainViewModelAction.Close.FullScreenSheet())
                                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(700)) {
                                        
                                        let navigationBarViewModel = NavigationBarView.ViewModel(
                                            title: "Все регионы",
                                            titleButton: .init(
                                                icon: Image.ic24ChevronDown,
                                                action: { [weak self] in
                                                    
                                                    self?.model.action.send(QRSearchOperatorViewModelAction.OpenCityView())
                                                }),
                                            leftItems: [
                                                NavigationBarView.ViewModel.BackButtonItemViewModel(
                                                    icon: .ic24ChevronLeft,
                                                    action: { [weak self] in self?.route = nil })
                                            ])
                                        
                                        let operatorsViewModel = QRSearchOperatorViewModel(
                                            searchBar: .nameOrTaxCode(),
                                            navigationBar: navigationBarViewModel, 
                                            model: self.model,
                                            operators: operators, 
                                            addCompanyAction: { [weak self] in
                                                
                                                self?.route = nil
                                                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                                                    
                                                    self?.rootActions?.switchTab(.chat)
                                                }
                                            },
                                            requisitesAction: { [weak self] in
                                                
                                                self?.route = nil
                                                self?.action.send(MainViewModelAction.Show.Requisites(qrCode: qr))
                                            },
                                            qrCode: qr)
                                        
                                        self.route = .link(.searchOperators(operatorsViewModel))
                                    }
                                }
                                
                            } else {
                                
                                self.route = nil
                                self.action.send(MainViewModelAction.Show.Requisites(qrCode: qr))
                            }
                            
                        } else {
                            
                            self.action.send(MainViewModelAction.Close.FullScreenSheet())
                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(700)) {
                                
                                let failedView = QRFailedViewModel(model: self.model, addCompanyAction: { [weak self] in
                                    
                                    self?.route = nil
                                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                                        self?.rootActions?.switchTab(.chat)
                                    }
                                    
                                }, requisitsAction: { [weak self] in
                                    
                                    self?.route = nil
                                    self?.action.send(MainViewModelAction.Show.Requisites(qrCode: qr))
                                })
                                self.route = .link(.failedView(failedView))
                            }
                        }
                        
                    case .c2bURL(let url):
                        
                        self.action.send(MainViewModelAction.Close.FullScreenSheet())
                        Task.detached(priority: .high) { [self] in
                            
                            do {
                                
                                let operationViewModel = try await PaymentsViewModel(source: .c2b(url), model: model, closeAction: { [weak self] in
                                    self?.action.send(MainViewModelAction.Close.Link())})
                                bind(operationViewModel)
                                
                                await MainActor.run {
                                    
                                    route = .link(.payments(operationViewModel))
                                }
                                
                            } catch {
                                
                                await MainActor.run {
                                    
                                    self.route = .alert(.init(title: "Ошибка C2B оплаты по QR", message: error.localizedDescription, primary: .init(type: .default, title: "Ok", action: {[weak self] in self?.route = nil })))
                                }
                                
                                LoggerAgent.shared.log(level: .error, category: .ui, message: "Unable create PaymentsViewModel for c2b subscribtion with error: \(error.localizedDescription) ")
                            }
                        }
                        
                    case .c2bSubscribeURL(let url):
                        self.action.send(MainViewModelAction.Close.FullScreenSheet())
                        let paymentsViewModel = PaymentsViewModel(source: .c2bSubscribe(url), model: model, closeAction: { [weak self] in
                            self?.action.send(MainViewModelAction.Close.Link())
                        })
                        bind(paymentsViewModel)
                        
                        self.action.send(DelayWrappedAction(
                            delayMS: 700,
                            action: MainViewModelAction.Show.Payments(paymentsViewModel: paymentsViewModel))
                        )
                        
                    case .url(_):
                        
                        self.action.send(MainViewModelAction.Close.FullScreenSheet())
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(700)) {
                            
                            let failedView = QRFailedViewModel(model: self.model, addCompanyAction: { [weak self] in
                                
                                self?.route = nil
                                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                                    self?.rootActions?.switchTab(.chat)
                                }
                                
                            }, requisitsAction: { [weak self] in
                                
                                guard let self else { return }
                                
                                self.action.send(MainViewModelAction.Close.FullScreenSheet())
                                let paymentsViewModel = PaymentsViewModel(model, service: .requisites, closeAction: { [weak self] in
                                    self?.action.send(MainViewModelAction.Close.Link())
                                })
                                self.bind(paymentsViewModel)
                                
                                self.action.send(DelayWrappedAction(
                                    delayMS: 700,
                                    action: MainViewModelAction.Show.Payments(paymentsViewModel: paymentsViewModel))
                                )
                            })
                            self.route = .link(.failedView(failedView))
                        }
                        
                    case .unknown:
                        
                        self.action.send(MainViewModelAction.Close.FullScreenSheet())
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(700)) {
                            
                            let failedView = QRFailedViewModel(model: self.model, addCompanyAction: { [weak self] in
                                
                                self?.route = nil
                                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                                    self?.rootActions?.switchTab(.chat)
                                }
                                
                            }, requisitsAction: { [weak self] in
                                
                                guard let self else { return }
                                
                                self.action.send(MainViewModelAction.Close.FullScreenSheet())
                                let paymentsViewModel = PaymentsViewModel(model, service: .requisites, closeAction: { [weak self] in
                                    self?.action.send(MainViewModelAction.Close.Link())
                                })
                                self.bind(paymentsViewModel)
                                
                                self.action.send(DelayWrappedAction(
                                    delayMS: 700,
                                    action: MainViewModelAction.Show.Payments(paymentsViewModel: paymentsViewModel))
                                )
                            })
                            self.route = .link(.failedView(failedView))
                        }
                    }
                    
                default:
                    break
                }
            }
            .store(in: &bindings)
    }
    
    func bind(_ paymentsViewModel: PaymentsViewModel) {
        
        paymentsViewModel.action
            .compactMap { $0 as? PaymentsViewModelAction.ScanQrCode }
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
            
                let qrScannerModel = QRViewModel.init(
                    closeAction: { [weak self] in
                        
                        self?.route = nil
                    })
                
                bind(qrScannerModel)
                route = .fullScreenSheet(.init(type: .qrScanner(qrScannerModel)))
            }
            .store(in: &bindings)
    }
    
    func bind(_ productProfile: ProductProfileViewModel) {
        
        productProfile.action
            .compactMap { $0 as? ProductProfileViewModelAction.MyProductsTapped.OpenDeposit }
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in self.openDeposit() }
            .store(in: &bindings)
    }
    
    func bind(_ templatesListViewModel: TemplatesListViewModel) {
        
        templatesListViewModel.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case _ as TemplatesListViewModelAction.CloseAction:
                    self.action.send(DelayWrappedAction(
                        delayMS: 800,
                        action: MainViewModelAction.Close.Link())
                    )
                    
                case let payload as TemplatesListViewModelAction.OpenProductProfile:
                    
                    self.action.send(MainViewModelAction.Close.Link())
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(800)) {
                        self.action.send(MainViewModelAction.Show.ProductProfile
                            .init(productId: payload.productId))
                    }
                    
                default:
                    break
                }
            }
            .store(in: &bindings)
    }
    
    func bind(_ viewModel: ContactsViewModel) {
        
        viewModel.action
            .compactMap({ $0 as? ContactsViewModelAction.PaymentRequested })
            .map(\.source)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] payloadSource in
                
                self.action.send(MainViewModelAction.Close.Sheet())
                
                let source: Payments.Operation.Source? = {
                    
                    //TODO: move all this logic to payments with source side
                    switch payloadSource {
                    case let .latestPayment(latestPaymentId):
                        guard let latestPayment = model.latestPayments.value.first(where: { $0.id == latestPaymentId }) as? PaymentGeneralData else {
                            return nil
                        }
                        return .sfp(phone: latestPayment.phoneNumber, bankId: latestPayment.bankId)
                        
                        
                    default:
                        return payloadSource
                    }
                    
                }()
                
                guard let source else { return }
                
                let paymentsViewModel = PaymentsViewModel(source: source, model: model) { [weak self] in
                    
                    guard let self else { return }
                    
                    self.action.send(PaymentsTransfersViewModelAction.Close.Link())
                    self.action.send(DelayWrappedAction(
                        delayMS: 300,
                        action: MainViewModelAction.Show.Contacts())
                    )
                }
                bind(paymentsViewModel)
                
                self.action.send(DelayWrappedAction(
                    delayMS: 300,
                    action: MainViewModelAction.Show.Payments(paymentsViewModel: paymentsViewModel))
                )
            }
            .store(in: &bindings)
    }
    
    func update(_ sections: [MainSectionViewModel], with settings: MainSectionsSettings) {
        
        for section in sections {
            
            guard let collapsableSection = section as? MainSectionCollapsableViewModel else {
                continue
            }
            
            if let isCollapsed = settings.collapsed[section.type] {
                
                collapsableSection.isCollapsed = isCollapsed
                
            } else {
                
                collapsableSection.isCollapsed = false
            }
        }
    }
    
    func createNavButtonsRight() -> [NavigationBarButtonViewModel] {
        
        [.init(
            icon: .ic24Bell,
            action: { [weak self] in
                
                self?.action.send(MainViewModelAction.ButtonTapped.Messages())
            }
        )]
    }
    
    private func openDeposit() {
        
        let openDepositViewModel = OpenDepositViewModel(
            model,
            catalogType: .deposit,
            dismissAction: { [weak self] in
                
                self?.action.send(MainViewModelAction.Close.Link())
            })
        
        route = .link(.openDepositsList(openDepositViewModel))
    }
}

// MARK: Helpers

extension MainViewModel {
    
    class UserAccountButtonViewModel: ObservableObject {
        
        let logo: Image
        @Published var avatar: Image?
        @Published var name: String
        
        let action: () -> Void
        
        internal init(logo: Image, name: String, avatar: Image?, action: @escaping () -> Void) {
            self.logo = logo
            self.name = name
            self.avatar = avatar
            self.action = action
        }
        
        func update(clientInfo: ClientInfoData?, clientPhoto: ClientPhotoData?, clientName: ClientNameData?) {
            
            guard let clientInfo = clientInfo else { return }
            
            self.name = clientName?.name ?? clientInfo.firstName
            self.avatar = clientPhoto?.photo.image
            
        }
    }
    
    enum Route {
        
        case alert(Alert.ViewModel)
        case bottomSheet(BottomSheet)
        case fullScreenSheet(FullScreenSheet)
        case link(Link)
        case sheet(Sheet)
        
        var alert: Alert.ViewModel? {
            if case let .alert(alert) = self {
                
                return alert
            } else {
                
                return nil
            }
        }
        
        var bottomSheet: BottomSheet? {
            if case let .bottomSheet(bottomSheet) = self {
                
                return bottomSheet
            } else {
                
                return nil
            }
        }
        
        var fullScreenSheet: FullScreenSheet? {
            if case let .fullScreenSheet(fullScreenSheet) = self {
                
                return fullScreenSheet
            } else {
                
                return nil
            }
        }
        
        var link: Link? {
            if case let .link(link) = self {
                
                return link
            } else {
                
                return nil
            }
        }
        
        var sheet: Sheet? {
            if case let .sheet(sheet) = self {
                
                return sheet
            } else {
                
                return nil
            }
        }
    }
    
    struct Sheet: Identifiable {
        
        let id = UUID()
        let type: Kind
        
        enum Kind {
            
            case places(PlacesViewModel)
            case byPhone(ContactsViewModel)
        }
    }
    
    enum Link: Identifiable {
        
        case userAccount(UserAccountViewModel)
        case productProfile(ProductProfileViewModel)
        case messages(MessagesHistoryViewModel)
        case openDeposit(OpenDepositDetailViewModel)
        case openDepositsList(OpenDepositViewModel)
        case templates(TemplatesListViewModel)
        case currencyWallet(CurrencyWalletViewModel)
        case myProducts(MyProductsViewModel)
        case country(CountryPaymentView.ViewModel)
        case serviceOperators(OperatorsViewModel)
        case failedView(QRFailedViewModel)
        case searchOperators(QRSearchOperatorViewModel)
        case openCard(AuthProductsViewModel)
        case payments(PaymentsViewModel)
        case operatorView(InternetTVDetailsViewModel)
        case paymentsServices(PaymentsServicesViewModel)
        case landing(LandingWrapperViewModel)
        case orderSticker(LandingWrapperViewModel)
        case paymentSticker
        
        var id: Case {
            
            switch self {
            case .userAccount:
                return .userAccount
            case .productProfile:
                return .productProfile
            case .messages:
                return .messages
            case .openDeposit:
                return .openDeposit
            case .openDepositsList:
                return .openDepositsList
            case .templates:
                return .templates
            case .currencyWallet:
                return .currencyWallet
            case .myProducts:
                return .myProducts
            case .country:
                return .country
            case .serviceOperators:
                return .serviceOperators
            case .failedView:
                return .failedView
            case .searchOperators:
                return .searchOperators
            case .openCard:
                return .openCard
            case .payments:
                return .payments
            case .operatorView:
                return .operatorView
            case .paymentsServices:
                return .paymentsServices
            case .landing:
                return .landing
            case .orderSticker:
                return .orderSticker
            case .paymentSticker:
                return .paymentSticker
            }
        }
        
        enum Case {
            
            case userAccount
            case productProfile
            case messages
            case openDeposit
            case openDepositsList
            case templates
            case currencyWallet
            case myProducts
            case country
            case serviceOperators
            case failedView
            case searchOperators
            case openCard
            case payments
            case operatorView
            case paymentsServices
            case paymentSticker
            case landing
            case orderSticker
        }
    }
    
    struct BottomSheet: BottomSheetCustomizable {

        let id = UUID()
        let type: BottomSheetType
        
        enum BottomSheetType {
            
            case openAccount(OpenAccountViewModel)
            case clientInform(ClientInformViewModel)
        }
    }
    
    struct FullScreenSheet: Identifiable, Equatable {

        let id = UUID()
        let type: Kind
        
        enum Kind {
            
            case qrScanner(QRViewModel)
        }
        
        static func == (lhs: MainViewModel.FullScreenSheet, rhs: MainViewModel.FullScreenSheet) -> Bool {
            lhs.id == rhs.id
        }
    }
}

extension MainViewModel {
    
    func handleLandingAction(_ abroadType: AbroadType) {
        
        let viewModel = factory.makeStickerLandingViewModel(
            abroadType,
            config: .stickerDefault,
            landingActions: landingAction
        )
        
        UIApplication.shared.endEditing()
        route = .link(.landing(viewModel))
    }
    
    private func landingAction(for event: LandingEvent.Sticker) -> () -> Void {
        
        switch event {
        case .goToMain:
            return handleCloseLinkAction
        case .order:
            return orderSticker
        }
    }
    
    private func handleCloseLinkAction() {
        
        LoggerAgent.shared.log(category: .ui, message: "received AuthLoginViewModelAction.Close.Link")
        route = nil
    }
    
    func orderSticker() {
        
        let productsCard = model.products(.card)
        
        if productsCard == nil ||
            productsCard?.contains(where: {
                ($0 as? ProductCardData)?.isMain == true }) == false
        {
            
            self.route = .alert(.init(
                title: "Нет карты", message: "Сначала нужно заказать карту.", primary: .init(
                    type: .default, title: "Отмена", action: {}), secondary: .init(
                        type: .default, title: "Продолжить", action: {
                            
                            DispatchQueue.main.async {
                                let authProductsViewModel = AuthProductsViewModel(
                                    self.model,
                                    products: self.model.catalogProducts.value,
                                    dismissAction: { [weak self] in
                                        self?.action.send(MyProductsViewModelAction.Close.Link()) })
                                
                                self.route = .link(.openCard(authProductsViewModel))
                            }
                        }
                    )))
        } else {
            
            self.route = .link(.paymentSticker)
        }
        
        /* TODO: v4 сейчас нет
         если по запросу rest/v4/getProductListByType?productType=CARD нет карт с параметрами:
         cardType: MAIN - главная карта. или cardType: REGULAR - обычная карта.
         */
    }
}

//MARK: - Action

enum MainViewModelAction {
    
    enum ButtonTapped {
        
        struct UserAccount: Action {}
        
        struct Search: Action {}
        
        struct Messages: Action {}
    }
    
    struct OpenProduct: Action {}
    
    struct PullToRefresh: Action {}
    
    enum Close {
        
        struct Link: Action {}
        
        struct Sheet: Action {}
        
        struct FullScreenSheet: Action {}
    }
    
    enum Show {
        
        struct ProductProfile: Action {
            
            let productId: ProductData.ID
        }
        
        struct ContactPayment: Action {}
        
        struct Requisites: Action {
            
            let qrCode: QRCode
        }
        
        struct Payments: Action {
            
            let paymentsViewModel: PaymentsViewModel
        }
        
        struct Contacts: Action {}
        
        struct Countries: Action {}
    }
}

