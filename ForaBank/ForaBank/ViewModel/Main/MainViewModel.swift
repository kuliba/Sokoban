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
                         MainSectionCurrencyView.ViewModel(model),
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
                    link = .openDeposit(openDepositViewModel)
                    
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
                    
                default:
                    break
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
                                bottomSheet = .init(type: .openAccount(model))
                                
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
                                link = .templates(.init(model, dismissAction: {[weak self] in self?.action.send(MainViewModelAction.Close.Link())
                                }))
                                
                            case .byPhone:
                                sheet = .init(type: .byPhone(.init(closeAction: { [weak self] in
                                    self?.action.send(MainViewModelAction.Close.Sheet())
                                })))
                            case .byQr:
                                if model.cameraAgent.isCameraAvailable {
                                    model.cameraAgent.requestPermissions(completion: { available in
                                        
                                        if available {
                                            self.link = .qrScanner(.init(closeAction: { [weak self] in
                                                self?.action.send(MainViewModelAction.Close.Link())
                                            }))
                                        } else {
                                            self.alert = .init(
                                                title: "Внимание",
                                                message: "Для сканирования QR кода, необходим доступ к камере",
                                                primary: .init(type: .cancel, title: "Понятно", action: {
                                                }))
                                        }
                                    })
                                }
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
                        
                        let walletViewModel = makeCurrencyWalletViewModel(currency: payload.code, currencyOperation: .buy)
                    
                        guard let walletViewModel = walletViewModel else {
                            return
                        }
                        
                        model.action.send(ModelAction.Dictionary.UpdateCache.List(types: [.currencyWalletList, .currencyList]))
                        link = .currencyWallet(walletViewModel)
                        
                    case let payload as MainSectionViewModelAction.CurrencyMetall.DidTapped.Buy:
                        
                        guard let walletViewModel = makeCurrencyWalletViewModel(currency: payload.code, currencyOperation: .buy) else {
                            return
                        }
                        
                        model.action.send(ModelAction.Dictionary.UpdateCache.List(types: [.currencyWalletList, .currencyList]))
                        link = .currencyWallet(walletViewModel)
                        
                    case let payload as MainSectionViewModelAction.CurrencyMetall.DidTapped.Sell:
                        
                        guard let walletViewModel = makeCurrencyWalletViewModel(currency: payload.code, currencyOperation: .sell) else {
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
    
    private func makeCurrencyWalletViewModel(currency: Currency, currencyOperation: CurrencyOperation) -> CurrencyWalletViewModel? {
        
        let currencyWalletList = model.currencyWalletList.value
        let currencyList = model.currencyList.value
        let images = model.images.value
        
        let items = CurrencyListViewModel.reduceCurrencyWallet(currencyWalletList, images: images, currency: currency)
        let item = items.first(where: { $0.currency.description == currency.description })
        let data = currencyList.first(where: { $0.code == currency.description })
        
        guard let item = item, let currencySymbol = data?.currencySymbol else {
            return nil
        }
        
        let walletViewModel: CurrencyWalletViewModel = .init(model, currency: currency, currencyItem: item, currencyOperation: currencyOperation, currencySymbol: currencySymbol) { [weak self] in
            self?.action.send(MainViewModelAction.Close.Link())
        }
        
        return walletViewModel
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
                    self.action.send(MainViewModelAction.Close.Sheet())
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                        
                        self.action.send(MainViewModelAction.Show.ProductProfile(productId: payload.productId))
                    }
                    
                case _ as MyProductsViewModelAction.Tapped.OpenDeposit:
                    self.action.send(MainViewModelAction.Close.Sheet())
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                        
                        self.action.send(MainViewModelAction.Show.OpenDeposit())
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
        }
    }
    
    enum Link {
        
        case userAccount(UserAccountViewModel)
        case productProfile(ProductProfileViewModel)
        case messages(MessagesHistoryViewModel)
        case openDeposit(OpenDepositViewModel)
        case templates(TemplatesListViewModel)
        case qrScanner(QrViewModel)
        case currencyWallet(CurrencyWalletViewModel)
        case myProducts(MyProductsViewModel)
    }

    struct BottomSheet: Identifiable {

        let id = UUID()
        let type: BottomSheetType

        enum BottomSheetType {

            case openAccount(Model)
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
    }
    
    enum Show {
    
        struct ProductProfile: Action {
            
            let productId: ProductData.ID
        }
        
        struct OpenDeposit: Action {}
    }

}

