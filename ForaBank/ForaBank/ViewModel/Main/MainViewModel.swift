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
    @Published var link: Link? { didSet { isLinkActive = link != nil } }
    @Published var isLinkActive: Bool = false
    
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
                         MainSectionFastOperationView.ViewModel.sample,
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
                    let userAccountViewModel: UserAccountViewModel = .init(model: model, clientInfo: clientInfo)
                    sheet = .init(type: .userAccount(userAccountViewModel))
                    
                case _ as MainViewModelAction.ButtonTapped.Messages:
                    let messagesHistoryViewModel: MessagesHistoryViewModel = .sample
                    sheet = .init(type: .messages(messagesHistoryViewModel))
                    
                case _ as MainViewModelAction.PullToRefresh:
                    model.action.send(ModelAction.Products.Update.Total.All())
                
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
            
            section.action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                        // products section
                    case let payload as MainSectionViewModelAction.Products.ProductDidTapped:
                        let productProfileViewModel: ProductProfileViewModel = .init(productViewModel: .init(model, productId: payload.productId, productType: .card), model: model, dismissAction: { [weak self] in self?.link = nil })
//                        sheet = .init(type: .productProfile(productProfileViewModel))
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
            case userAccount(UserAccountViewModel)
            case messages(MessagesHistoryViewModel)
            case myProducts(MyProductsViewModel)
            case places(PlacesViewModel)
        }
    }
    
    enum Link {
        
        case productProfile(ProductProfileViewModel)
    }
}

enum MainViewModelAction {

    enum ButtonTapped {
        
        struct UserAccount: Action {}
        
        struct Search: Action {}
        
        struct Messages: Action {}
    }
    
    struct PullToRefresh: Action {}
}

