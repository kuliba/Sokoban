//
//  MainViewModel.swift
//  ForaBank
//
//  Created by Max Gribov on 24.02.2022.
//

import Foundation
import Combine
import SwiftUI

class MainViewModel: ObservableObject, Resetable {
    
    let action: PassthroughSubject<Action, Never> = .init()
    
    lazy var userAccountButton: UserAccountButtonViewModel = .init(logo: .ic12LogoForaColor, name: "", avatar: nil, action: { [weak self] in self?.action.send(MainViewModelAction.ButtonTapped.UserAccount())})
    let refreshingIndicator: RefreshingIndicatorView.ViewModel
    @Published var navButtonsRight: [NavigationBarButtonViewModel]
    @Published var sections: [MainSectionViewModel]
    @Published var productProfile: ProductProfileViewModel?
    @Published var sheet: Sheet?
    @Published var link: Link? { didSet { isLinkActive = link != nil; isTabBarHidden = link != nil } }
    @Published var isLinkActive: Bool = false
    @Published var isTabBarHidden: Bool = false
    @Published var bottomSheet: BottomSheet?
    @Published var fullScreenSheet: FullScreenSheet?
    @Published var alert: Alert.ViewModel?
    
    var rootActions: RootViewModel.RootActions?
    
    private let model: Model
    private var bindings = Set<AnyCancellable>()
    
    init(refreshingIndicator: RefreshingIndicatorView.ViewModel, navButtonsRight: [NavigationBarButtonViewModel], sections: [MainSectionViewModel], model: Model = .emptyMock) {
        
        self.refreshingIndicator = refreshingIndicator
        self.navButtonsRight = navButtonsRight
        self.sections = sections
        self.model = model
    }
    
    init(_ model: Model) {
        
        self.refreshingIndicator = .init(isActive: false)
        self.navButtonsRight = []
        self.sections = [MainSectionProductsView.ViewModel(model),
                         MainSectionFastOperationView.ViewModel(),
                         MainSectionPromoView.ViewModel(model),
                         MainSectionCurrencyMetallView.ViewModel(model),
                         MainSectionOpenProductView.ViewModel(model),
                         MainSectionAtmView.ViewModel.initial]
        
        self.model = model
        
        navButtonsRight = createNavButtonsRight()
        bind()
        update(sections, with: model.settingsMainSections)
        bind(sections)
    }
    
    func reset() {
        
        sheet = nil
        link = nil
        bottomSheet = nil
        isTabBarHidden = false
        
        for section in sections {
            
            switch section {
            case let productsSection as MainSectionProductsView.ViewModel:
                productsSection.action.send(MainSectionViewModelAction.Products.ScrollToFirstGroup())
            default:
                continue
            }
        }
    }
    
    private func bind() {
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as MainViewModelAction.Show.ProductProfile:
                    guard let prooduct = model.products.value.values.flatMap({ $0 }).first(where: { $0.id == payload.productId }) else {
                        return
                    }
                    
                    guard let productProfileViewModel = ProductProfileViewModel(model, product: prooduct, dismissAction: { [weak self] in
                        self?.action.send(MainViewModelAction.Close.Link())
                    }) else {
                        return
                    }
                    productProfileViewModel.rootActions = rootActions
                    bind(productProfileViewModel)
                    link = .productProfile(productProfileViewModel)
                    
                case _ as MainViewModelAction.Show.OpenDeposit:
                    let openDepositViewModel = OpenDepositViewModel(model, catalogType: .deposit, dismissAction: {[weak self] in self?.action.send(MainViewModelAction.Close.Link())
                    })
                    link = .openDepositsList(openDepositViewModel)
                    
                case _ as MainViewModelAction.ButtonTapped.UserAccount:
                    guard let clientInfo = model.clientInfo.value else {
                        return
                    }
                    link = .userAccount(.init(model: model, clientInfo: clientInfo, dismissAction: {[weak self] in self?.action.send(MainViewModelAction.Close.Link())}))
                    
                case _ as MainViewModelAction.ButtonTapped.Messages:
                    let messagesHistoryViewModel: MessagesHistoryViewModel = .init(model: model, closeAction: {[weak self] in self?.action.send(MainViewModelAction.Close.Link())})
                    link = .messages(messagesHistoryViewModel)
                    
                case _ as MainViewModelAction.PullToRefresh:
                    model.action.send(ModelAction.Products.Update.Total.All())
                    model.action.send(ModelAction.Dictionary.UpdateCache.List(types: [.currencyWalletList, .currencyList]))
                    
                case _ as MainViewModelAction.Close.Link:
                    self.link = nil
                    
                case _ as MainViewModelAction.Close.Sheet:
                    self.sheet = nil
                    
                case _ as MainViewModelAction.Close.FullScreenSheet:
                    self.fullScreenSheet = nil
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
        
        model.products
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] products in
                
                guard model.depositsCloseNotified == nil else { return }
                
                let products = products.values.flatMap {$0}
                
                let deposits = products.filter({$0.productType == .deposit})
                
                for deposit in deposits {
                    
                    if let deposit = deposit as? ProductDepositData, let endDate = deposit.endDateNf, endDate {
                        
                        self.alert = .init(title: "Срок действия вклада истек", message: "Переведите деньги со вклада на свою карту/счет в любое время", primary: .init(type: .default, title: "Отмена", action: {}), secondary: .init(type: .default, title: "Ok", action: {
                            
                            self.action.send(MainViewModelAction.Show.ProductProfile(productId: deposit.id))
                        }))
                        
                        self.model.action.send(ModelAction.Deposits.CloseNotified(productId: deposit.id))
                    }
                }
            }.store(in: &bindings)
        
        model.productsUpdating
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] productsUpdating in
                
                withAnimation {
                    
                    refreshingIndicator.isActive = productsUpdating.isEmpty ? false : true
                }
                
            }.store(in: &bindings)
        
        model.clientInfo
            .combineLatest(model.clientPhoto, model.clientName)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] clientData in
                
                userAccountButton.update(clientInfo: clientData.0, clientPhoto: clientData.1, clientName: clientData.2)
                
            }.store(in: &bindings)
    }
    
    private func bind(_ sections: [MainSectionViewModel]) {
        
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
                                let items = OpenAccountViewModel.reduce(products: accountProductsList)
                                
                                let openAccountViewModel: OpenAccountViewModel = .init(model: model, items: items, currency: .rub)
                                
                                bottomSheet = .init(type: .openAccount(openAccountViewModel))
                                
                            case .deposit:
                                self.action.send(MainViewModelAction.Show.OpenDeposit())
                                
                            default:
                                break
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
                                
                                let templatesListviewModel = TemplatesListViewModel(
                                    model, dismissAction: { [weak self] in self?.action.send(MainViewModelAction.Close.Link()) })
                                bind(templatesListviewModel)
                                link = .templates(templatesListviewModel)
                                
                            case .byPhone:
                                sheet = .init(type: .byPhone(.init(closeAction: { [weak self] in
                                    self?.action.send(MainViewModelAction.Close.Sheet())
                                })))
                            case .byQr:
                                
                                let qrScannerModel = QRViewModel.init(closeAction: { [weak self] in
                                    self?.action.send(MainViewModelAction.Close.FullScreenSheet())
                                })

                                bind(qrScannerModel)
                                fullScreenSheet = .init(type: .qrScanner(qrScannerModel)) 
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
                                
                                if let openDepositViewModel: OpenProductViewModel = .init(depositId: payload.depositProductId) {
                                    
                                    self.link = .openDeposit(openDepositViewModel)
                                }
                            case _ as BannerActionDepositsList:
                                
                                self.link = .openDepositsList(.init(model, catalogType: .deposit, dismissAction: { [weak self] in
                                    self?.action.send(MainViewModelAction.Close.Link())
                                }))
                            case let payload as BannerActionMigTransfer:
                                
                                self.link = .country(.init(country: payload.countryId, operatorsViewModel: .init(closeAction: { [weak self] in
                                    self?.action.send(MainViewModelAction.Close.Link())
                                }, mode: .general), paymentType: .withOutAddress(withOutViewModel: .init(phoneNumber: nil))))
                                
                            case let payload as BannerActionContactTransfer:
                                
                                self.link = .country(.init(country: payload.countryId, operatorsViewModel: .init(closeAction: { [weak self] in
                                    self?.action.send(MainViewModelAction.Close.Link())
                                }, mode: .general), paymentType: .turkeyWithOutAddress(turkeyWithOutAddress: .init(firstName: "", middleName: "", surName: "", phoneNumber: ""))))
                                
                            default: break
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
                        
                    case _ as MainSectionViewModelAction.Products.MoreButtonTapped:
                        let myProductsViewModel = MyProductsViewModel(model, dismissAction: { [weak self] in self?.action.send(MainViewModelAction.Close.Link()) })
                        bind(myProductsViewModel)
                        link = .myProducts(myProductsViewModel)
                        
                        // CurrencyMetall section
                        
                    case let payload as MainSectionViewModelAction.CurrencyMetall.DidTapped.Item:
                        
                        guard let walletViewModel = CurrencyWalletViewModel(currency: payload.code, currencyOperation: .buy, model: model, dismissAction: { [weak self] in
                            self?.action.send(MainViewModelAction.Close.Link())}) else {
                            return
                        }
                        
                        model.action.send(ModelAction.Dictionary.UpdateCache.List(types: [.currencyWalletList, .currencyList]))
                        link = .currencyWallet(walletViewModel)
                        
                    case let payload as MainSectionViewModelAction.CurrencyMetall.DidTapped.Buy:
                        
                        guard let walletViewModel = CurrencyWalletViewModel(currency: payload.code, currencyOperation: .buy, model: model, dismissAction: { [weak self] in
                            self?.action.send(MainViewModelAction.Close.Link())}) else {
                            return
                        }
                        
                        model.action.send(ModelAction.Dictionary.UpdateCache.List(types: [.currencyWalletList, .currencyList]))
                        link = .currencyWallet(walletViewModel)
                        
                    case let payload as MainSectionViewModelAction.CurrencyMetall.DidTapped.Sell:
                        
                        guard let walletViewModel = CurrencyWalletViewModel(currency: payload.code, currencyOperation: .sell, model: model, dismissAction: { [weak self] in
                            self?.action.send(MainViewModelAction.Close.Link())}) else {
                            return
                        }
                        
                        model.action.send(ModelAction.Dictionary.UpdateCache.List(types: [.currencyWalletList, .currencyList]))
                        link = .currencyWallet(walletViewModel)
                        
                        // atm section
                    case _ as MainSectionViewModelAction.Atm.ButtonTapped:
                        guard let placesViewModel = PlacesViewModel(model) else {
                            return
                        }
                        sheet = .init(type: .places(placesViewModel))
                        
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
    
    func bind(_ qrViewModel: QRViewModel ) {
        
        qrViewModel.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as QRViewModelAction.Result:
                    
                    switch payload.result {
                    case .qrCode(let qr):
                        
                        //TODO: REFACTOR
                        if let qrMapping = model.qrMapping.value {
                            
                            if let operators = model.dictionaryAnywayOperators(with: qr, mapping: qrMapping) {
                                
                                if operators.count == 1 {
                                    
                                    self.action.send(MainViewModelAction.Close.FullScreenSheet())
                                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(700)) {
                                        
                                        let operatorsViewModel = OperatorsViewModel(closeAction: { [weak self] in
                                            self?.link = nil
                                        }, mode: .qr(qr))
                                        self.link = .serviceOperators(operatorsViewModel)
                                    }
                                    
                                } else {
                                    
                                    //TODO: QRSearchOperatorViewModel with operators
                                    self.action.send(MainViewModelAction.Close.FullScreenSheet())
                                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(700)) {
                                        
                                        let operatorsViewModel = QRSearchOperatorViewModel(textFieldPlaceholder: "Название или ИНН", navigationBar:
                                                .init(
                                                    title: "Все регионы",
                                                    titleButton: .init(icon: Image.ic16ChevronDown, action: {
                                                        self.model.action.send(QRSearchOperatorViewModelAction.OpenCityView())
                                                    }),
                                                    leftButtons: [NavigationBarView.ViewModel.BackButtonViewModel(icon: Image.ic24ChevronLeft,
                                                                                                                  action: { [weak self] in
                                                                                                                      self?.link = nil})]),
                                                                                           model: self.model, operators: operators)
                                        
                                        self.link = .searchOperators(operatorsViewModel)
                                    }
                                }
                                
                            } else {
                                
                                self.action.send(MainViewModelAction.Close.FullScreenSheet())
                                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(700)) {
                                    
                                    let failedView = QRFailedViewModel(model: self.model)
                                    self.link = .failedView(failedView)
                                }
                            }
                            
                        } else {
                            self.action.send(MainViewModelAction.Close.FullScreenSheet())
                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(700)) {
                                
                                let failedView = QRFailedViewModel(model: self.model)
                                self.link = .failedView(failedView)
                            }
                        }

                    case .c2bURL(let c2bURL):
                        
                        // show c2b payment after delay required to finish qr scanner close animation
                        self.action.send(MainViewModelAction.Close.FullScreenSheet())
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(700)) {
                    
                            let c2bViewModel = C2BViewModel(urlString: c2bURL.absoluteString, closeAction: { [weak self] in
                                self?.action.send(MainViewModelAction.Close.Link())
                            })
                            
                            self.link = .c2b(c2bViewModel)
                        }

                    case .url( _):
                        
                        self.action.send(MainViewModelAction.Close.FullScreenSheet())
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(700)) {
                            
                            let failedView = QRFailedViewModel(model: self.model)
                            self.link = .failedView(failedView)
                        }
                        
                    case .unknown(_):
                        
                        self.action.send(MainViewModelAction.Close.FullScreenSheet())
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(700)) {
                            
                            let failedView = QRFailedViewModel(model: self.model)
                            self.link = .failedView(failedView)
                        }
                    }
                    
                   
                    
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
    }
    
    private func bind(_ productProfile: ProductProfileViewModel) {
        
        productProfile.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as ProductProfileViewModelAction.MyProductsTapped.ProductProfile:
                    
                    self.action.send(MainViewModelAction.Close.Link())
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(800)) {
                        
                        self.action.send(MainViewModelAction.Show.ProductProfile(productId: payload.productId))
                    }
                    
                case _ as ProductProfileViewModelAction.MyProductsTapped.OpenDeposit:
                    self.action.send(MainViewModelAction.Close.Link())
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(800)) {
                        
                        self.action.send(MainViewModelAction.Show.OpenDeposit())
                    }
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
    }
    
    
    
    private func bind(_ myProductsViewModel: MyProductsViewModel) {
        
        myProductsViewModel.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as MyProductsViewModelAction.Tapped.Product:
                    
                    self.action.send(MainViewModelAction.Close.Link())
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(800)) {
                        
                        self.action.send(MainViewModelAction.Show.ProductProfile(productId: payload.productId))
                    }
                    
                case _ as MyProductsViewModelAction.Tapped.OpenDeposit:
                    
                    self.action.send(MainViewModelAction.Close.Link())
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(800)) {
                        
                        self.action.send(MainViewModelAction.Show.OpenDeposit())
                    }
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
    }
    
    private func bind(_ templatesListViewModel: TemplatesListViewModel) {
        
        templatesListViewModel.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case _ as TemplatesListViewModelAction.AddTemplate:
                    
                    self.action.send(MainViewModelAction.Close.Link())
                    if let productFirst = model.products.value.values.flatMap({ $0 }).first {
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(800)) {
                            self.action.send(MainViewModelAction.Show.ProductProfile(productId: productFirst.id))
                        }
                    }
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
    }
    
    private func update(_ sections: [MainSectionViewModel], with settings: MainSectionsSettings) {
        
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
    
    private func createNavButtonsRight() -> [NavigationBarButtonViewModel] {
        
        [.init(icon: .ic24Bell, action: {[weak self] in self?.action.send(MainViewModelAction.ButtonTapped.Messages())})]
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
    
    struct Sheet: Identifiable {
        
        let id = UUID()
        let type: Kind
        
        enum Kind {
            
            case productProfile(ProductProfileViewModel)
            case messages(MessagesHistoryViewModel)
            case places(PlacesViewModel)
            case byPhone(TransferByPhoneViewModel)
            case openAccount(OpenAccountViewModel)
//            case qrScanner(QRViewModel)
        }
    }
    
    enum Link {
        
        case userAccount(UserAccountViewModel)
        case productProfile(ProductProfileViewModel)
        case messages(MessagesHistoryViewModel)
        case openDeposit(OpenProductViewModel)
        case openDepositsList(OpenDepositViewModel)
        case templates(TemplatesListViewModel)
        case currencyWallet(CurrencyWalletViewModel)
        case myProducts(MyProductsViewModel)
        case country(CountryPaymentView.ViewModel)
        case serviceOperators(OperatorsViewModel)
        case failedView(QRFailedViewModel)
        case c2b(C2BViewModel)
        case searchOperators(QRSearchOperatorViewModel)
    }
    
    struct BottomSheet: Identifiable {
        
        let id = UUID()
        let type: BottomSheetType
        
        enum BottomSheetType {
            
            case openAccount(OpenAccountViewModel)
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
        
        struct OpenDeposit: Action {}
    }
    
}

