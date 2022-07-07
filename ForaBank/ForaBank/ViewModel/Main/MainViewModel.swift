//
//  MainViewModel.swift
//  ForaBank
//
//  Created by Max Gribov on 24.02.2022.
//

import Foundation
import Combine
import SwiftUI

class MainViewModel: ObservableObject {
    
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
                         MainSectionFastOperationView.ViewModel.init(),
                         MainSectionPromoView.ViewModel(model),
                         MainSectionCurrencyMetallView.ViewModel(),
                         MainSectionOpenProductView.ViewModel(model),
                         MainSectionAtmView.ViewModel.initial]
        
        self.model = model
        
        navButtonsRight = createNavButtonsRight()
        bind()
        update(sections, with: model.settingsMainSections)
        bind(sections)
    }
    
    private func bind() {
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case _ as MainViewModelAction.ButtonTapped.UserAccount:
                    guard let clientInfo = model.clientInfo.value else {
                        return
                    }
                    link = .userAccount(.init(model: model, clientInfo: clientInfo, dismissAction: {[weak self] in self?.action.send(MainViewModelAction.CloseAction.Link())}))
                    
                case _ as MainViewModelAction.ButtonTapped.Messages:
                    let messagesHistoryViewModel: MessagesHistoryViewModel = .init(model: model, closeAction: {[weak self] in self?.action.send(MainViewModelAction.CloseAction.Link())})
                    link = .messages(messagesHistoryViewModel)
                    
                case _ as MainViewModelAction.PullToRefresh:
                    model.action.send(ModelAction.Products.Update.Total.All())
                
                case _ as MainViewModelAction.CloseAction.Link:
                    self.link = nil
                    
                case _ as MainViewModelAction.CloseAction.Sheet:
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
        
        model.notificationsTransition
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] transition in
               
                switch transition {
                case .history:
                    let messagesHistoryViewModel: MessagesHistoryViewModel = .init(model: model, closeAction: {
                        self.action.send(MainViewModelAction.CloseAction.Link())
                    })
                    link = .messages(messagesHistoryViewModel)
                    model.notificationsTransition.value = nil
                default:
                    break
                }
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
                                link = .openDeposit(.init(model, products: self.model.deposits.value, style: .deposit, dismissAction: {[weak self] in self?.action.send(MainViewModelAction.CloseAction.Link())
                                }))
                                
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
                                link = .templates(.init(model, dismissAction: {[weak self] in self?.action.send(MainViewModelAction.CloseAction.Link())
                                }))
                                
                            case .byPhone:
                                sheet = .init(type: .byPhone(.init(closeAction: { [weak self] in
                                    self?.action.send(MainViewModelAction.CloseAction.Sheet())
                                })))
                            case .byQr:
                                link = .qrScanner(.init(closeAction: { [weak self] in
                                    self?.action.send(MainViewModelAction.CloseAction.Link())
                                }))
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
                    
                        guard let prooduct = model.products.value.values.flatMap({ $0 }).first(where: { $0.id == payload.productId }),
                            let productProfileViewModel = ProductProfileViewModel(model, product: prooduct, dismissAction: { [weak self] in self?.action.send(MainViewModelAction.CloseLink()) }) else {
                            return
                        }
                        productProfileViewModel.rootActions = rootActions
                        link = .productProfile(productProfileViewModel)
                        
                    case _ as MainSectionViewModelAction.Products.MoreButtonTapped:
                        let myProductsViewModel: MyProductsViewModel = .init(model)
                        sheet = .init(type: .myProducts(myProductsViewModel))
                        
                        // CurrencyMetall section
                    case let payload as MainSectionViewModelAction.CurrencyMetall.ItemDashboardDidTapped.Buy :
                    
                        print("mdy: Buy-\(payload.itemData)") // -> USD, GBR, EUR
                        
                    case let payload as MainSectionViewModelAction.CurrencyMetall.ItemDashboardDidTapped.Sell :
                    
                        print("mdy: Sell-\(payload.itemData)") // -> USD, GBR, EUR
                        
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
        
        [.init(icon: .ic24Search, action: {[weak self] in self?.action.send(MainViewModelAction.ButtonTapped.Search())}),
         .init(icon: .ic24Bell, action: {[weak self] in self?.action.send(MainViewModelAction.ButtonTapped.Messages())})]
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
            
            self.name = clientName ?? clientInfo.firstName
            self.avatar = clientPhoto?.image
            
        }
    }
    
    struct Sheet: Identifiable {
        
        let id = UUID()
        let type: Kind
        
        enum Kind {
            
            case productProfile(ProductProfileViewModel)
            case messages(MessagesHistoryViewModel)
            case myProducts(MyProductsViewModel)
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
    
    enum CloseAction {
     
        struct Link: Action {}
        
        struct Sheet: Action {}
    }
}

