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

    lazy var userAccountButton: UserAccountButtonViewModel = UserAccountButtonViewModel(logo: .ic12LogoForaColor, avatar: nil, name: "Александр", action: { [weak self] in self?.action.send(MainViewModelAction.ButtonTapped.UserAccount())})
    @Published var navButtonsRight: [NavigationBarButtonViewModel]
    @Published var sections: [MainSectionViewModel]
    @Published var isRefreshing: Bool
    @Published var productProfile: ProductProfileViewModel?
    @Published var sheet: Sheet?
    
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
        self.sections = [MainSectionProductsView.ViewModel(model), MainSectionFastOperationView.ViewModel.sample, MainSectionPromoView.ViewModel.sample, MainSectionCurrencyView.ViewModel.sample, MainSectionOpenProductView.ViewModel.sample, MainSectionAtmView.ViewModel(content: "Выберите ближайшую точку на карте", isCollapsed: false)]
        
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
                    let userAccountViewModel: UserAccountViewModel = .init(model: model)
                    sheet = .userAccount(userAccountViewModel)
                    
                case _ as MainViewModelAction.ButtonTapped.Messages:
                    let messagesHistoryViewModel: MessagesHistoryViewModel = .sample
                    sheet = .messages(messagesHistoryViewModel)
                    
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
    }
    
    private func bind(_ sections: [MainSectionViewModel]) {
        
        for section in sections {
            
            section.action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                        // products section
                    case let payload as MainSectionViewModelAction.Products.ProductDidTapped:
                        let productProfileViewModel: ProductProfileViewModel = .init(productViewModel: .init(model, productId: payload.productId, productType: .card), model: model)
                        sheet = .productProfile(productProfileViewModel)
                        
                    case _ as MainSectionViewModelAction.Products.MoreButtonTapped:
                        let myProductsViewModel: MyProductsViewModel = .init(model)
                        sheet = .myProducts(myProductsViewModel)
                       
                        // atm section
                    case _ as MainSectionViewModelAction.Atm.ButtonTapped:
                        guard let placesViewModel = PlacesViewModel(model) else {
                            return
                        }
                        sheet = .places(placesViewModel)
                        
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
        
        [.init(icon: .ic24Search, action: {[weak self] in self?.action.send(MainViewModelAction.ButtonTapped.Search())}), .init(icon: .ic24Bell, action: {[weak self] in self?.action.send(MainViewModelAction.ButtonTapped.Messages())})]
    }
}

extension MainViewModel {
    
    class UserAccountButtonViewModel: ObservableObject {
        
        @Published var logo: Image
        @Published var avatar: Image?
        @Published var name: String
        let action: () -> Void
        
        init(logo: Image, avatar: Image?, name: String, action: @escaping () -> Void) {
            
            self.logo = logo
            self.avatar = avatar
            self.name = name
            self.action = action
        }
    }
    
    enum Sheet: Identifiable {
        
        var id: UUID { UUID() }
        
        case productProfile(ProductProfileViewModel)
        case userAccount(UserAccountViewModel)
        case messages(MessagesHistoryViewModel)
        case myProducts(MyProductsViewModel)
        case places(PlacesViewModel)
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

