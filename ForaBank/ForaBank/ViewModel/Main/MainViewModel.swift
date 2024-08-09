//
//  MainViewModel.swift
//  ForaBank
//
//  Created by Max Gribov on 24.02.2022.
//

import Combine
import CombineSchedulers
import ForaTools
import Foundation
#warning("remove GenericRemoteService")
import GenericRemoteService
import SberQR
import SwiftUI
import LandingUIComponent
import PaymentSticker

class MainViewModel: ObservableObject, Resetable {
    
    typealias Templates = PaymentsTransfersFactory.Templates
    typealias TemplatesNode = PaymentsTransfersFactory.TemplatesNode
    typealias MakeProductProfileViewModel = (ProductData, String, @escaping () -> Void) -> ProductProfileViewModel?
    
    let action: PassthroughSubject<Action, Never> = .init()
    let routeSubject = PassthroughSubject<Route, Never>()
    
    lazy var userAccountButton: UserAccountButtonViewModel = .init(
        logo: MainViewModel.logo,
        name: "",
        avatar: nil,
        action: { [weak self] in self?.action.send(MainViewModelAction.ButtonTapped.UserAccount())}
    )
    
    @Published var navButtonsRight: [NavigationBarButtonViewModel]
    @Published var sections: [MainSectionViewModel]
    @Published var productProfile: ProductProfileViewModel?
    
    @Published var route: Route
    
    var rootActions: RootViewModel.RootActions?
    
    private let model: Model
    private let makeProductProfileViewModel: MakeProductProfileViewModel
    private let navigationStateManager: UserAccountNavigationStateManager
    private let sberQRServices: SberQRServices
    private let qrViewModelFactory: QRViewModelFactory
    private let paymentsTransfersFactory: PaymentsTransfersFactory
    private let onRegister: () -> Void
    private let authFactory: ModelAuthLoginViewModelFactory
    private let updateInfoStatusFlag: UpdateInfoStatusFeatureFlag
    
    private var bindings = Set<AnyCancellable>()
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        _ model: Model,
        route: Route = .empty,
        makeProductProfileViewModel: @escaping MakeProductProfileViewModel,
        navigationStateManager: UserAccountNavigationStateManager,
        sberQRServices: SberQRServices,
        qrViewModelFactory: QRViewModelFactory,
        paymentsTransfersFactory: PaymentsTransfersFactory,
        updateInfoStatusFlag: UpdateInfoStatusFeatureFlag,
        onRegister: @escaping () -> Void,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.model = model
        self.updateInfoStatusFlag = updateInfoStatusFlag
        self.navButtonsRight = []
        self.sections = Self.getSections(model, updateInfoStatusFlag: updateInfoStatusFlag, stickerViewModel: nil)
        
        self.authFactory = ModelAuthLoginViewModelFactory(model: model, rootActions: .emptyMock)
        self.makeProductProfileViewModel = makeProductProfileViewModel
        self.navigationStateManager = navigationStateManager
        self.sberQRServices = sberQRServices
        self.qrViewModelFactory = qrViewModelFactory
        self.paymentsTransfersFactory = paymentsTransfersFactory
        self.route = route
        self.onRegister = onRegister
        self.scheduler = scheduler
        self.navButtonsRight = createNavButtonsRight()
        
        bind()
        update(sections, with: model.settingsMainSections)
        bind(sections)
    }
    
    private static func getSections(
        _ model: Model,
        updateInfoStatusFlag: UpdateInfoStatusFeatureFlag,
        stickerViewModel: ProductCarouselView.StickerViewModel? = nil
    ) -> [MainSectionViewModel] {
        
        var sections = [
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
        if updateInfoStatusFlag.isActive {
            if !model.updateInfo.value.areProductsUpdated {
                sections.insert(UpdateInfoViewModel.init(content: .updateInfoText), at: 0)
            }
        }
        return sections
    }
    
    private func makeStickerViewModel(
        _ model: Model
    ) -> ProductCarouselView.StickerViewModel? {
        
        return ProductCarouselView.ViewModel.makeStickerViewModel(model) { [weak self] in
            self?.handleLandingAction(.sticker)
        } hide: { [weak self] in
            model.settingsAgent.saveShowStickerSetting(shouldShow: false)
            self?.removeSticker(model)
        }
    }
    
    func createSticker(
        _ model: Model
    ) {
        if sections.stickerViewModel == nil,
           let stickerViewModel = makeStickerViewModel(model) {
            updateSticker(model, stickerViewModel: stickerViewModel)
        }
    }
    
    private func updateSticker(
        _ model: Model,
        stickerViewModel: ProductCarouselView.StickerViewModel
    ) {
        if let index = sections.indexProductsSection,
            let section = sections[index] as? MainSectionProductsView.ViewModel,
           section.productCarouselViewModel.stickerViewModel?.backgroundImage != stickerViewModel.backgroundImage {
            sections[index] = MainSectionProductsView.ViewModel(
                model,
                stickerViewModel: stickerViewModel
            )
            bind(sections)
        }
    }
    
    private func removeSticker(_ model: Model) {
        
        if let index = sections.indexProductsSection {
            
            sections[index] = MainSectionProductsView.ViewModel(
                model,
                stickerViewModel: nil
            )
            bind(sections)
        }
    }
    
    private func updateProducts(
        _ model: Model
    ) {
        if let index = sections.indexProductsSection,
            let section = sections[index] as? MainSectionProductsView.ViewModel {
            
            withAnimation {
                sections[index] = MainSectionProductsView.ViewModel(
                    model,
                    stickerViewModel: section.productCarouselViewModel.stickerViewModel
                )
            }
            bind(sections)
        }
    }
}

extension MainViewModel {
    
    static let logo: Image = .ic12LogoForaColor
    
    func reset() {
        
        resetDestination()
        resetModal()
        
        for section in sections {
            
            switch section {
            case let productsSection as MainSectionProductsView.ViewModel:
                productsSection.action.send(MainSectionViewModelAction.Products.ResetScroll())
            default:
                continue
            }
        }
    }
    
    func resetDestination() {
        
        route.destination = nil
    }
    
    func resetModal() {
        
        route.modal = nil
    }
    
    private func openScanner() {
        
        let qrModel = qrViewModelFactory.makeQRScannerModel()
        let cancellable = bind(qrModel)
        var route = route
        route.modal = .fullScreenSheet(.init(
            type: .qrScanner(.init(
                model: qrModel,
                cancellable: cancellable
            ))
        ))
        routeSubject.send(route)
    }
    
    func openTemplates() {
        
        let templates = paymentsTransfersFactory.makeTemplates { [weak self] in
            
            self?.action.send(MainViewModelAction.Close.Link())
        }
        let cancellable = bind(templates)
        var route = route
        route.destination = .templates(.init(
            model: templates,
            cancellable: cancellable
        ))
        routeSubject.send(route)
    }
    
    func dismissPaymentProviderPicker() {
        
        guard case .paymentProviderPicker = route.destination
        else { return }
        
        route.destination = nil
        openScanner()
    }
    
    func dismissProviderServicePicker() {
        
        guard case .providerServicePicker = route.destination
        else { return }
        
        route.destination = nil
        openScanner()
    }
    
    func goToChat() {
        
        resetDestination()
        resetModal()
        
        delay(for: .milliseconds(400)) { [weak self] in
            
            self?.rootActions?.switchTab(.chat)
        }
    }
    
    func payByInstructions(
        withQR qrCode: QRCode
    ) {
        self.action.send(MainViewModelAction.Show.Requisites(qrCode: qrCode))
    }
}

private extension MainViewModel {
    
    func bind() {
        
        routeSubject
            .receive(on: scheduler)
            .assign(to: &$route)
        
        model.images
            .receive(on: scheduler)
            .sink { [weak self] _ in
                guard let self else { return }
                self.createSticker(self.model)
            }
            .store(in: &bindings)
        
        if updateInfoStatusFlag.isActive {
            model.updateInfo
                .receive(on: scheduler)
                .sink { [weak self] updateInfo in
                    
                    self?.updateSections(updateInfo)
                }
                .store(in: &bindings)
        }
        
        action
            .receive(on: scheduler)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as MainViewModelAction.Show.ProductProfile:
                    guard let product = model.product(productId: payload.productId),
                          let productProfileViewModel = makeProductProfileViewModel(
                            product,
                            "\(type(of: self))",
                            { [weak self] in self?.resetDestination() })
                    else { return }
                    
                    productProfileViewModel.rootActions = rootActions
                    productProfileViewModel.contactsAction = { [weak self] in self?.showContacts() }
                    bind(productProfileViewModel)
                    route.destination = .productProfile(productProfileViewModel)
                    
                case _ as MainViewModelAction.ButtonTapped.UserAccount:
                    guard let clientInfo = model.clientInfo.value else {
                        return
                    }
                    
                    model.action.send(ModelAction.C2B.GetC2BSubscription.Request())
                    
#warning("replace with injected factory")
                    route.destination = .userAccount(.init(
                        navigationStateManager: navigationStateManager,
                        model: model,
                        clientInfo: clientInfo,
                        dismissAction: { [weak self] in self?.resetDestination() }
                    ))
                    
                case _ as MainViewModelAction.ButtonTapped.Messages:
                    let messagesHistoryViewModel: MessagesHistoryViewModel = .init(model: model, closeAction: {[weak self] in self?.action.send(MainViewModelAction.Close.Link())})
                    route.destination = .messages(messagesHistoryViewModel)
                    
                case _ as MainViewModelAction.PullToRefresh:
                    model.action.send(ModelAction.Products.Update.Total.All())
                    model.action.send(ModelAction.Dictionary.UpdateCache.List(types: [.currencyWalletList, .currencyList, .bannerCatalogList]))
                    
                case _ as MainViewModelAction.Close.Link:
                    resetDestination()
                    
                case _ as MainViewModelAction.Close.Sheet:
                    resetModal()
                    
                case _ as MainViewModelAction.Close.FullScreenSheet:
                    resetModal()
                    
                case _ as PaymentsViewModelAction.ScanQrCode:
                    self.openScanner()
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
        
        action
            .compactMap({ $0 as? MainViewModelAction.Show.Requisites })
            .map(\.qrCode)
            .receive(on: scheduler)
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
            .receive(on: scheduler)
            .sink(receiveValue: { [unowned self] paymentsViewModel in
                
                route.destination = .payments(paymentsViewModel)
                
            }).store(in: &bindings)
        
        action
            .compactMap({ $0 as? MainViewModelAction.Show.Contacts })
            .receive(on: scheduler)
            .sink(receiveValue: { [unowned self] _ in
                
                let contactsViewModel = model.makeContactsViewModel(forMode: .fastPayments(.contacts))
                bind(contactsViewModel)
                
                route.modal = .sheet(.init(type: .byPhone(contactsViewModel)))
                
            }).store(in: &bindings)
        
        action
            .compactMap({ $0 as? MainViewModelAction.Show.Countries })
            .receive(on: scheduler)
            .sink(receiveValue: { [unowned self] _ in
                
                let contactsViewModel = model.makeContactsViewModel(forMode: .abroad)
                bind(contactsViewModel)
                
                route.modal = .sheet(.init(type: .byPhone(contactsViewModel)))
                
            }).store(in: &bindings)
        
        action
            .compactMap({ $0 as? DelayWrappedAction })
            .flatMap({
                
                Just($0.action)
                    .delay(for: .milliseconds($0.delayMS), scheduler: self.scheduler)
            })
            .sink(receiveValue: { [weak self] in
                
                self?.action.send($0)
                
            }).store(in: &bindings)
        
        model.productsOrdersUpdating
            .receive(on: scheduler)
            .sink { [weak self] in
                guard let self else { return }
                
                if !$0 { self.updateProducts(model) }
            }.store(in: &bindings)
        
        model.products
            .receive(on: scheduler)
            .sink { [unowned self] products in
                guard let deposits = products[.deposit], !deposits.isEmpty else { return }
                
                let filteredDeposits = deposits.filter { deposit in
                    guard let deposit = deposit as? ProductDepositData else { return false }
                    return !self.model.depositsCloseNotified.contains(.init(depositId: deposit.depositId)) && deposit.endDateNf
                }
                
                var previousDepositData: (expired: Date?, id: Int?) = (nil, nil)
                
                filteredDeposits.forEach { deposit in
                    guard let deposit = deposit as? ProductDepositData else { return }
                    
                    self.model.action.send(ModelAction.Deposits.CloseNotified(productId: deposit.depositId))
                    previousDepositData = returnFirstExpiredDepositID(previousData: previousDepositData, newData: (deposit.endDate, deposit.depositId))
                    
                }
                
                if let productId = previousDepositData.id {
                    self.route.modal = .alert(.init(
                        title: "Срок действия вклада истек",
                        message: "Переведите деньги со вклада на свою карту/счет в любое время",
                        primary: .init(type: .default, title: "Отмена", action: {}),
                        secondary: .init(type: .default, title: "Ok", action: {
                            self.action.send(MainViewModelAction.Show.ProductProfile(productId: productId))
                        })
                    ))
                }
            }.store(in: &bindings)
        
        model.clientInfo
            .combineLatest(model.clientPhoto, model.clientName)
            .receive(on: scheduler)
            .sink { [unowned self] clientData in
                
                userAccountButton.update(clientInfo: clientData.0, clientPhoto: clientData.1, clientName: clientData.2)
                
            }.store(in: &bindings)
    }
    
    func bind(_ sections: [MainSectionViewModel]) {
        
        for section in sections {
            
            switch section {
            case let openProductSection as MainSectionOpenProductView.ViewModel:
                openProductSection.action
                    .receive(on: scheduler)
                    .sink { [weak self] action in
                            
                        guard let self else { return }

                        switch action {
                        case let payload as MainSectionViewModelAction.OpenProduct.ButtonTapped:
                            
                            switch payload.productType {
                            case .account:
                                
                                let accountProductsList = model.accountProductsList.value
                                
                                guard let openAccountViewModel: OpenAccountViewModel = .init(model, products: accountProductsList) else {
                                    return
                                }
                                
                                route.modal = .bottomSheet(.init(type: .openAccount(openAccountViewModel)))
                                
                            case .deposit:
                                self.openDeposit()
                                
                            case .card:
                                
                                let authProductsViewModel = AuthProductsViewModel(
                                    self.model,
                                    products: self.model.catalogProducts.value,
                                    dismissAction: { [weak self] in
                                        self?.action.send(MainViewModelAction.Close.Link())
                                    })
                                
                                route.destination =  .openCard(authProductsViewModel)
                                
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
                    .receive(on: scheduler)
                    .sink { [unowned self] action in
                        
                        switch action {
                        case let payload as MainSectionViewModelAction.FastPayment.ButtonTapped:
                            switch payload.operationType {
                            case .templates:
                                self.openTemplates()
                                
                            case .byPhone:
                                self.action.send(MainViewModelAction.Show.Contacts())
                                
                            case .byQr:
                                self.openScanner()
                            }
                            
                        default:
                            break
                        }
                        
                    }.store(in: &bindings)
                
                // Promo section
            case let promo as MainSectionPromoView.ViewModel:
                promo.action
                    .receive(on: scheduler)
                    .sink { [unowned self] action in
                        
                        switch action {
                        case let payload as MainSectionViewModelAction.PromoAction.ButtonTapped:
                            switch payload.actionData {
                            case let payload as BannerActionDepositOpen:
                                guard let depositId = Int(payload.depositProductId),
                                      let openDepositViewModel: OpenDepositDetailViewModel = .init(depositId: depositId, model: model) else {
                                    
                                    return
                                }
                                route.destination = .openDeposit(openDepositViewModel)
                                
                            case _ as BannerActionDepositsList:
                                route.destination = .openDepositsList(.init(model, catalogType: .deposit, dismissAction: { [weak self] in
                                    self?.action.send(MainViewModelAction.Close.Link())
                                }))
                                
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
                .receive(on: scheduler)
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
                            makeProductProfileViewModel: makeProductProfileViewModel,
                            openOrderSticker: {
                                
                                self.route = .empty
                                
                                self.delay(for: .milliseconds(700)) { [self] in
                                    
                                    handleLandingAction(.sticker)
                                }
                            },
                            makeMyProductsViewFactory: .init(makeInformerDataUpdateFailure: { [weak self] in
                                
                                guard let self else { return nil }
                                
                                if self.updateInfoStatusFlag.isActive {
                                    return .updateFailureInfo
                                }
                                return nil
                            })
                        )
                        myProductsViewModel.rootActions = rootActions
                        myProductsViewModel.contactsAction = { [weak self] in self?.showContacts() }
                        route.destination = .myProducts(myProductsViewModel)
                        
                        // CurrencyMetall section
                        
                    case let payload as MainSectionViewModelAction.CurrencyMetall.DidTapped.Item:
                        
                        guard let walletViewModel = CurrencyWalletViewModel(currency: payload.code, currencyOperation: .buy, model: model, dismissAction: { [weak self] in
                            self?.action.send(MainViewModelAction.Close.Link())}) else {
                            return
                        }
                        
                        model.action.send(ModelAction.Dictionary.UpdateCache.List(types: [.currencyWalletList, .currencyList]))
                        model.action.send(ModelAction.Account.ProductList.Request())
                        route.destination = .currencyWallet(walletViewModel)
                        
                    case let payload as MainSectionViewModelAction.CurrencyMetall.DidTapped.Buy:
                        
                        guard let walletViewModel = CurrencyWalletViewModel(currency: payload.code, currencyOperation: .buy, model: model, dismissAction: { [weak self] in
                            self?.action.send(MainViewModelAction.Close.Link())}) else {
                            return
                        }
                        
                        model.action.send(ModelAction.Dictionary.UpdateCache.List(types: [.currencyWalletList, .currencyList]))
                        model.action.send(ModelAction.Account.ProductList.Request())
                        route.destination = .currencyWallet(walletViewModel)
                        
                    case let payload as MainSectionViewModelAction.CurrencyMetall.DidTapped.Sell:
                        
                        guard let walletViewModel = CurrencyWalletViewModel(currency: payload.code, currencyOperation: .sell, model: model, dismissAction: { [weak self] in
                            self?.action.send(MainViewModelAction.Close.Link())}) else {
                            return
                        }
                        
                        model.action.send(ModelAction.Dictionary.UpdateCache.List(types: [.currencyWalletList, .currencyList]))
                        model.action.send(ModelAction.Account.ProductList.Request())
                        route.destination = .currencyWallet(walletViewModel)
                        
                        // atm section
                    case _ as MainSectionViewModelAction.Atm.ButtonTapped:
                        guard let placesViewModel = PlacesViewModel(model) else {
                            return
                        }
                        route.modal = .sheet(.init(type: .places(placesViewModel)))
                        
                    default:
                        break
                        
                    }
                }.store(in: &bindings)
            
            if let collapsableSection = section as? MainSectionCollapsableViewModel {
                
                collapsableSection.$isCollapsed
                    .dropFirst()
                    .receive(on: scheduler)
                    .sink { [unowned self] isCollapsed in
                        
                        var settings = model.settingsMainSections
                        settings.update(sectionType: collapsableSection.type, isCollapsed: isCollapsed)
                        model.settingsMainSectionsUpdate(settings)
                        
                    }.store(in: &bindings)
            }
        }
    }
    
    func bind(_ qrModel: QRModel) -> AnyCancellable {
        
        qrModel.$state
            .compactMap { $0 }
            .debounce(for: 0.1, scheduler: scheduler)
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
    
    private func bind(_ paymentsViewModel: PaymentsViewModel) {
        
        paymentsViewModel.action
            .receive(on: scheduler)
            .sink { [unowned self] action in
                
                switch action {
                    
                case _ as PaymentsViewModelAction.ScanQrCode:
                    self.openScanner()
                    
                default: break
                }
            }
            .store(in: &bindings)
    }
    
    func bind(_ productProfile: ProductProfileViewModel) {
        
        productProfile.action
            .compactMap { $0 as? ProductProfileViewModelAction.MyProductsTapped.OpenDeposit }
            .receive(on: scheduler)
            .sink { [unowned self] _ in self.openDeposit() }
            .store(in: &bindings)
    }
    
    func bind(
        _ templates: Templates
    ) -> AnyCancellable {
        
        templates.$state
            .map(\.outside)
            .receive(on: scheduler)
            .sink { [weak self] in self?.handleTemplatesFlowOutsideState($0) }
    }
    
    private func handleTemplatesFlowOutsideState(
        _ outside: Templates.State.Status.Outside?
    ) {
        switch outside {
        case .none:
            rootActions?.spinner.hide()

        case .inflight:
            rootActions?.spinner.show()
            
        case let .productID(productID):
            rootActions?.spinner.hide()
            action.send(MainViewModelAction.Close.Link())
            
            delay(for: .milliseconds(800)) { [weak self] in
                
                self?.action.send(
                    MainViewModelAction.Show.ProductProfile(
                        productId: productID
                    )
                )
            }
        }
    }
    
    func bind(_ viewModel: ContactsViewModel) {
        
        viewModel.action
            .compactMap({ $0 as? ContactsViewModelAction.PaymentRequested })
            .map(\.source)
            .receive(on: scheduler)
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
        
        let openDepositViewModel = OpenDepositListViewModel(
            model,
            catalogType: .deposit,
            dismissAction: { [weak self] in
                
                self?.action.send(MainViewModelAction.Close.Link())
            })
        
        route.destination = .openDepositsList(openDepositViewModel)
    }
    
    private typealias DepositeID = Int
    private func returnFirstExpiredDepositID(
        previousData: (expired: Date?, DepositeID?),
        newData: (Date?, DepositeID)
    ) -> (Date?, DepositeID) {
        
        if previousData.1 == nil {
            return (newData.0, newData.1)
        }
        
        if let previousDate = previousData.0,
           let newDate = newData.0,
           let newID = previousData.1,
           newDate < previousDate {
            
            return (newDate, newID)
        } else {
            
            return (previousData.0, previousData.1 ?? 0)
        }
    }
    
    private func showContacts() {
        
        self.resetDestination()
        
        self.delay(for: .milliseconds(300)) { [weak self] in
            
            self?.rootActions?.switchTab(.chat)
        }
    }
    
    func updateSections(_ updateInfo: UpdateInfo) {
        
        let containUpdateInfoSection: Bool = sections.first(where: { $0.type == .updateInfo }) is UpdateInfoViewModel
        switch (updateInfo.areProductsUpdated, containUpdateInfoSection) {
            
        case (true, true):
            sections.removeFirst()
        case (false, false):
            sections.insert(UpdateInfoViewModel.init(content: .updateInfoText), at: 0)
        default:
            break
        }
    }
}

// MARK: - Templates

extension TemplatesListFlowState {
    
    var outside: Status.Outside? {
        
        guard case let .outside(outside) = status
        else { return nil }
 
        return outside
    }
}

// MARK: - QR

extension MainViewModel {
    
    private func handleQRResult(
        _ result: QRModelResult
    ) {
        resetModal()
        
        switch result {
        case let .c2bSubscribeURL(url):
            handleC2bSubscribeURL(url)
            
        case let .c2bURL(url):
            handleC2bURL(url)
            
        case let .failure(qrCode):
            handleFailure(qrCode)
            
        case let .mapped(mapped):
            handleMapped(mapped)
            
        case let .sberQR(url):
            handleSberQRURL(url)
            
        case let .url(url):
            handleURL(url)
            
        case .unknown:
            handleUnknownQR()
        }
    }
    
    private func handleMapped(
        _ mapped: QRModelResult.Mapped
    ) {
        switch mapped {
        case let .mixed(mixed, qrCode, qrMapping):
            makePaymentProviderPicker(mixed, qrCode, qrMapping)
            
        case let .multiple(multipleOperators, qrCode, qrMapping):
            searchOperators(multipleOperators, with: qrCode)
            
        case let .none(qrCode):
            payByInstructions(with: qrCode)
            
        case let .provider(payload):
            makeServicePicker(payload)
            
        case let .single(`operator`, qrCode, qrMapping):
            let viewModel = InternetTVDetailsViewModel(
                model: model,
                qrCode: qrCode,
                mapping: qrMapping
            )
            
            self.route.destination = .operatorView(viewModel)
            
        case let .source(source):
            makePayment(with: source)
        }
    }

    private func makePayment(
        with source: Payments.Operation.Source
    ) {
        let paymentsViewModel = PaymentsViewModel(
            source: source,
            model: model,
            closeAction: { [weak self] in
                
                self?.model.action.send(PaymentsTransfersViewModelAction.Close.Link())
            }
        )
        bind(paymentsViewModel)
        
        route.destination = .payments(paymentsViewModel)
    }
    
    private func searchOperators(
        _ operators: MultiElementArray<SegmentedOperatorData>,
        with qr: QRCode
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
                    action: { [weak self] in self?.resetDestination() }
                )
            ]
        )
        
        let operatorsViewModel = QRSearchOperatorViewModel(
            searchBar: .nameOrTaxCode(),
            navigationBar: navigationBarViewModel,
            model: self.model,
            operators: operators.elements.map(\.origin),
            addCompanyAction: { [weak self] in self?.addCompany() },
            requisitesAction: { [weak self] in self?.payByInstructions(with: qr) },
            qrCode: qr
        )
        
        route.destination = .searchOperators(operatorsViewModel)
    }
    
    private func handleFailure(
        _ qrCode: QRCode
    ) {
        let failedView = QRFailedViewModel(
            model: self.model,
            addCompanyAction: { [weak self] in self?.addCompany() },
            requisitsAction: { [weak self] in self?.payByInstructions(with: qrCode) }
        )
        self.route.destination = .failedView(failedView)
    }
    
    private func handleC2bURL(
        _ url: URL
    ) {
        Task.detached(priority: .high) { [self] in
            
            do {
                
                let operationViewModel = try await PaymentsViewModel(source: .c2b(url), model: model, closeAction: { [weak self] in
                    self?.action.send(MainViewModelAction.Close.Link())})
                bind(operationViewModel)
                
                await MainActor.run {
                    
                    self.route.destination = .payments(operationViewModel)
                }
                
            } catch {
                
                await MainActor.run {
                    
                    self.route.modal = .alert(.init(title: "Ошибка C2B оплаты по QR", message: error.localizedDescription, primary: .init(type: .default, title: "Ok", action: { [weak self] in self?.resetModal() })))
                }
                
                LoggerAgent.shared.log(level: .error, category: .ui, message: "Unable create PaymentsViewModel for c2b subscribtion with error: \(error.localizedDescription) ")
            }
        }
    }
    
    private func handleC2bSubscribeURL(
        _ url: URL
    ) {
        let paymentsViewModel = PaymentsViewModel(
            source: .c2bSubscribe(url),
            model: model,
            closeAction: { [weak self] in
                
                self?.action.send(MainViewModelAction.Close.Link())
            }
        )
        bind(paymentsViewModel)
        
        self.action.send(DelayWrappedAction(
            delayMS: 700,
            action: MainViewModelAction.Show.Payments(paymentsViewModel: paymentsViewModel))
        )
    }
    
    private func handleSberQRURL(
        _ url: URL
    ) {
        rootActions?.spinner.show()
        
        sberQRServices.getSberQRData(url) { [weak self] result in
            
            DispatchQueue.main.async { [weak self] in
                
                // TODO: move SberQR processing into QRModelWrapper.MapScanResult
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
            self.route.modal = .alert(.techError { [weak self] in self?.resetModal() })
            
        case let .success(getSberQRDataResponse):
            do {
                let viewModel = try qrViewModelFactory.makeSberQRConfirmPaymentViewModel(
                    getSberQRDataResponse,
                    { [weak self] in self?.sberQRPay(url: url, state: $0) }
                )
                route.destination = .sberQRPayment(viewModel)
                
            } catch {
                self.route.modal = .alert(.techError { [weak self] in self?.resetModal() })
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
        resetDestination()
        
        delay(for: .milliseconds(400)) { [weak self] in
            
            guard let self else { return }
            
            switch result {
            case .failure:
                self.route.modal = .alert(.techError { [weak self] in self?.resetModal() })
                
            case let .success(success):
                let successViewModel = qrViewModelFactory.makePaymentsSuccessViewModel(success)
                self.route.modal = .fullScreenSheet(.init(type: .success(successViewModel)))
            }
        }
    }
    
    private func handleURL(
        _ url: URL
    ) {
        let failedView = QRFailedViewModel(
            model: self.model,
            addCompanyAction: { [weak self] in self?.addCompany() },
            requisitsAction: { [weak self] in self?.payByInstructions() }
        )
        
        self.route.destination = .failedView(failedView)
    }
    
    private func handleUnknownQR() {
        
        let failedView = QRFailedViewModel(
            model: self.model,
            addCompanyAction: { [weak self] in self?.addCompany() },
            requisitsAction: { [weak self] in self?.payByInstructions() }
        )
        
        self.route.destination = .failedView(failedView)
    }
    
    private func addCompany() {
        
        resetDestination()
        
        delay(for: .milliseconds(300)) { [weak self] in
            
            self?.rootActions?.switchTab(.chat)
        }
    }
    
    private func payByInstructions() {
        
        resetDestination()
        resetModal()
        
        let paymentsViewModel = PaymentsViewModel(
            model,
            service: .requisites,
            closeAction: { [weak self] in
                
                self?.action.send(MainViewModelAction.Close.Link())
            }
        )
        self.bind(paymentsViewModel)
        
        self.action.send(DelayWrappedAction(
            delayMS: 700,
            action: MainViewModelAction.Show.Payments(paymentsViewModel: paymentsViewModel))
        )
    }
    
    private func payByInstructions(with qrCode: QRCode) {
        
        resetDestination()
        resetModal()

        action.send(MainViewModelAction.Show.Requisites(qrCode: qrCode))
    }
}

// MARK: - PaymentProviderPicker

private extension MainViewModel {
    
    func makePaymentProviderPicker(
        _ mixed: MultiElementArray<SegmentedOperatorProvider>,
        _ qrCode: QRCode,
        _ qrMapping: QRMapping
    ) {
        let flowModel = paymentsTransfersFactory.makePaymentProviderPickerFlowModel(mixed, qrCode, qrMapping)
        route.destination = .paymentProviderPicker(.init(
            model: flowModel,
            cancellables: bind(flowModel)
        ))
    }
    
    private func bind(
        _ flowModel: PaymentProviderPickerFlowModel
    ) -> Set<AnyCancellable> {
        
        let spinner = flowModel.$state
            .map(\.isLoading)
            .removeDuplicates()
            .receive(on: scheduler)
            .sink { [weak self] in self?.showSpinner($0) }
        
        let outside = flowModel.$state
            .compactMap(\.outside)
            .receive(on: scheduler)
            .sink { [weak self] in self?.handle($0) }
        
        return [spinner, outside]
    }
    
    private func showSpinner(_ isShowing: Bool) {
        
        if isShowing {
            rootActions?.spinner.show()
        } else {
            rootActions?.spinner.hide()
        }
    }
    
    func handle(
        _ outside: PaymentProviderPickerFlowState.Status.Outside
    ) {
        resetDestination()
        rootActions?.spinner.hide()
        
        delay(for: .milliseconds(300)) { [weak self] in
                        
            switch outside {
            case .addCompany:
                self?.rootActions?.switchTab(.chat)
                
            case .main:
                self?.rootActions?.switchTab(.main)

            case .payments:
                self?.rootActions?.switchTab(.payments)
                
            case .scanQR:
                self?.openScanner()
            }
        }
    }
}

extension PaymentProviderPickerFlowState {
    
    var outside: Status.Outside? {
        
        guard case let .outside(outside) = status
        else { return nil }
        
        return outside
    }
}

// MARK: - PaymentProviderServicePicker

private extension MainViewModel {
    
    func makeServicePicker(
        _ payload: PaymentProviderServicePickerPayload
    ) {
        let make = paymentsTransfersFactory.makePaymentProviderServicePickerFlowModel
        let flowModel = make(payload)
        route.destination = .providerServicePicker(.init(
            model: flowModel,
            cancellables: bind(flowModel)
        ))
    }
    
    private func bind(
        _ flowModel: AnywayServicePickerFlowModel
    ) -> Set<AnyCancellable> {
        
        let loading = flowModel.$state
            .map(\.isLoading)
            .removeDuplicates()
            .receive(on: scheduler)
            .sink { [weak self] in self?.showSpinner($0) }
        
        let outside = flowModel.$state
            .compactMap(\.outside)
            .removeDuplicates()
            .receive(on: scheduler)
            .sink { [weak self] in self?.handle($0) }
        
        return [loading, outside]
    }
    
    private func handle(
        _ outside: AnywayServicePickerFlowState.Status.Outside
    ) {
        resetDestination()
        
        delay(for: .milliseconds(300)) { [weak self] in
            
            switch outside {
            case .addCompany:
                self?.rootActions?.switchTab(.chat)
                
            case .main:
                self?.rootActions?.switchTab(.main)

            case .payments:
                self?.rootActions?.switchTab(.payments)
                
            case .scanQR:
                self?.openScanner()
            }
        }
    }
}

// MARK: - Helpers

extension MainViewModel {
    
    private func delay(
        for timeout: DispatchTimeInterval,
        _ action: @escaping () -> Void
    ) {
        // TODO: replace with scheduler
        scheduler.delay(for: timeout, action)
    }
}

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
    
    struct Route {
        
        var destination: Link?
        var modal: Modal?
        
        static let empty: Self = .init(destination: nil, modal: nil)
    }
    
    enum Modal {
        
        case alert(Alert.ViewModel)
        case bottomSheet(BottomSheet)
        case fullScreenSheet(FullScreenSheet)
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
            case productProfile(ProductProfileViewModel)
            case messages(MessagesHistoryViewModel)

        }
    }
    
    enum Link: Identifiable {
        
        case userAccount(UserAccountViewModel)
        case productProfile(ProductProfileViewModel)
        case messages(MessagesHistoryViewModel)
        case openDeposit(OpenDepositDetailViewModel)
        case openDepositsList(OpenDepositListViewModel)
        case templates(TemplatesNode)
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
        case sberQRPayment(SberQRConfirmPaymentViewModel)
        case landing(LandingWrapperViewModel)
        case orderSticker(LandingWrapperViewModel)
        case paymentSticker
        case paymentProviderPicker(Node<PaymentProviderPickerFlowModel>)
        case providerServicePicker(Node<AnywayServicePickerFlowModel>)
        
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
            case .sberQRPayment:
                return .sberQRPayment
            case .paymentProviderPicker:
                return .paymentProviderPicker
            case .providerServicePicker:
                return .providerServicePicker
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
            case sberQRPayment
            case paymentProviderPicker
            case providerServicePicker
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
            
            case qrScanner(Node<QRModel>)
            case success(PaymentsSuccessViewModel)
        }
        
        static func == (lhs: MainViewModel.FullScreenSheet, rhs: MainViewModel.FullScreenSheet) -> Bool {
            lhs.id == rhs.id
        }
    }
}

extension MainViewModel {
    
    func handleLandingAction(_ abroadType: AbroadType) {
        
        let viewModel = authFactory.makeStickerLandingViewModel(
            abroadType,
            config: .stickerDefault,
            landingActions: landingAction
        )
        
        UIApplication.shared.endEditing()
        route.destination = .landing(viewModel)
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
        resetDestination()
    }
    
    func orderSticker() {
        
        let productsCard = model.products(.card)
        
        if productsCard == nil ||
            productsCard?.contains(where: {
                ($0 as? ProductCardData)?.isMain == true }) == false
        {
            
            self.route.modal = .alert(.init(
                title: "Нет карты", message: "Сначала нужно заказать карту.", primary: .init(
                    type: .default, title: "Отмена", action: {}), secondary: .init(
                        type: .default, title: "Продолжить", action: {
                            
                            DispatchQueue.main.async {
                                let authProductsViewModel = AuthProductsViewModel(
                                    self.model,
                                    products: self.model.catalogProducts.value,
                                    dismissAction: { [weak self] in
                                        self?.action.send(MyProductsViewModelAction.Close.Link()) })
                                
                                self.route.destination = .openCard(authProductsViewModel)
                            }
                        }
                    )))
        } else {
            
            self.route.destination = .paymentSticker
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

extension Array where Element == MainSectionViewModel {
    
    var productsSection: MainSectionProductsView.ViewModel? {
        first(where: { $0.type == .products }) as? MainSectionProductsView.ViewModel
    }
    
    var indexProductsSection: Int? {
        firstIndex(where: { $0.type == .products })
    }
    
    var stickerViewModel: ProductCarouselView.StickerViewModel? {
        productsSection?.productCarouselViewModel.stickerViewModel
    }
}
