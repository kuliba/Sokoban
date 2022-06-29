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

    @Published var userAccountButton: UserAccountButtonViewModel?
    @Published var navButtonsRight: [NavigationBarButtonViewModel]
    @Published var sections: [MainSectionViewModel]
    @Published var isRefreshing: Bool
    @Published var productProfile: ProductProfileViewModel?
    @Published var sheet: Sheet?
    @Published var link: Link? { didSet { isLinkActive = link != nil; isTabBarHidden = link != nil } }
    @Published var isLinkActive: Bool = false
    @Published var isTabBarHidden: Bool = false
    @Published var bottomSheet: BottomSheet?
    
    private var model: Model
    private var bindings = Set<AnyCancellable>()
    
    init(navButtonsRight: [NavigationBarButtonViewModel], sections: [MainSectionViewModel], isRefreshing: Bool, model: Model = .emptyMock) {
        
        self.navButtonsRight = navButtonsRight
        self.sections = sections
        self.isRefreshing = isRefreshing
        self.model = model
    }
    
    init(_ model: Model) {
        
        self.navButtonsRight = []
        self.sections = [MainSectionProductsView.ViewModel(model),
                         MainSectionFastOperationView.ViewModel.init(),
                         MainSectionPromoView.ViewModel(model),
                         MainSectionCurrencyView.ViewModel(model),
                         MainSectionOpenProductView.ViewModel(model),
                         MainSectionAtmView.ViewModel.initial]
        
        self.isRefreshing = false
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
                    link = .userAccount(.init(model: model, clientInfo: clientInfo))
                    
                case _ as MainViewModelAction.ButtonTapped.Messages:
                    let messagesHistoryViewModel: MessagesHistoryViewModel = .init(model: model)
                    link = .messages(messagesHistoryViewModel)
                    
                case _ as MainViewModelAction.PullToRefresh:
                    model.action.send(ModelAction.Products.Update.Total.All())
                
                case _ as MainViewModelAction.CloseLink:
                    self.link = nil
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
        
        model.productsUpdating
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] productsUpdating in
                
                withAnimation {
                    
                    self.isRefreshing = productsUpdating.isEmpty ? false : true
                }
                
            }.store(in: &bindings)
        
        model.clientInfo
            .combineLatest(model.clientPhoto, model.clientName)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] clientData in
                
                userAccountButton = userAccountButton(clientInfo: clientData.0, clientPhoto: clientData.1, clientName: clientData.2)
                
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
                                link = .openDeposit(.init(model, products: self.model.deposits.value, style: .deposit))
                                
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
                                link = .templates(.init(model))
                            case .byPhone:
                                sheet = .init(type: .byPhone(.init(closeAction: { [weak self] in
                                    self?.sheet = nil
                                })))
                            default:
                                break
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
                            let productProfileViewModel = ProductProfileViewModel(model, product: prooduct, dismissAction: { [weak self] in self?.link = nil }) else {
                            return
                        }
                        link = .productProfile(productProfileViewModel)
                        
                    case _ as MainSectionViewModelAction.Products.MoreButtonTapped:
                        let myProductsViewModel: MyProductsViewModel = .init(model)
                        sheet = .init(type: .myProducts(myProductsViewModel))
                       
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
    
    private func userAccountButton(clientInfo: ClientInfoData?, clientPhoto: ClientPhotoData?, clientName: ClientNameData?) -> UserAccountButtonViewModel? {
        
        guard let clientInfo = clientInfo else {
            return nil
        }
        
        let name = clientName ?? clientInfo.firstName
        let avatar = clientPhoto?.image
        
        return  UserAccountButtonViewModel(logo: .ic12LogoForaColor, avatar: avatar, name: name, action: { [weak self] in self?.action.send(MainViewModelAction.ButtonTapped.UserAccount())})
    }
}

extension MainViewModel {
    
    struct UserAccountButtonViewModel {
        
        let logo: Image
        let avatar: Image?
        let name: String
        let action: () -> Void
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
    
    struct CloseLink: Action {}
}

