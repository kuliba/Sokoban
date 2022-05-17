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
    @Published var productProfile: ProfileViewModel?
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
        
    }
    
    func bind() {
        
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
                
                default:
                    break
                }
                
            }.store(in: &bindings)
        
        model.productsUpdateState
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] updateState in
                
                switch updateState {
                case .idle:
                    isRefreshing = false
                    
                case .updating:
                    isRefreshing = true
                }
                
            }.store(in: &bindings)
        
        for section in sections {
            
            switch section {
            case let productsSection as MainSectionProductsView.ViewModel:
                productsSection.action
                    .receive(on: DispatchQueue.main)
                    .sink { [unowned self] action in
                        
                        switch action {
                        case let payload as MainSectionProductsViewModelAction.ProductDidTapped:
                            let productProfileViewModel: ProfileViewModel = .init(productViewModel: .init(model, productId: payload.productId, productType: .card), model: model)
                            sheet = .productProfile(productProfileViewModel)
                            
                        case _ as MainSectionProductsViewModelAction.MoreButtonTapped:
                            let myProductsViewModel: MyProductsViewModel = .init(model)
                            sheet = .myProducts(myProductsViewModel)
                            
                        default:
                            break
                            
                        }
                        
                    }.store(in: &bindings)
                
            case let atmSection as MainSectionAtmView.ViewModel:
                atmSection.action
                    .receive(on: DispatchQueue.main)
                    .sink { [unowned self] action in
                        
                        switch action {
                        case _ as MainSectionAtmViewModelAction.ButtonTapped:
                            guard let placesViewModel = PlacesViewModel(model) else {
                                return
                            }
                            sheet = .places(placesViewModel)
                            
                        default:
                            break
                            
                        }
                        
                    }.store(in: &bindings)
                
            default:
                break
            }
        }
    }
    

    
    func createNavButtonsRight() -> [NavigationBarButtonViewModel] {
        
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
        
        case productProfile(ProfileViewModel)
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
}

