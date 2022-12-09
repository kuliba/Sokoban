//
//  MyProductsViewModel.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 10.04.2022.
//  Full refactored by Dmitry Martynov on 18.09.2022
//

import Combine
import UIKit
import SwiftUI

class MyProductsViewModel: ObservableObject {

    let action: PassthroughSubject<Action, Never> = .init()

    @Published var sections: [MyProductsSectionViewModel]
    @Published var bottomSheet: BottomSheet?
    @Published var link: Link? { didSet { isLinkActive = link != nil } }
    @Published var isLinkActive: Bool = false
    @Published var editModeState: EditMode
    @Published var showOnboarding: [Onboarding: Bool]

    var navigationBar: NavigationBarView.ViewModel
    let totalMoneyVM: MyProductsMoneyViewModel
    let openProductVM: MyProductsOpenProductView.ViewModel
    var refreshingIndicator: RefreshingIndicatorView.ViewModel
    let openProductTitle = "Открыть продукт"
    var rootActions: RootViewModel.RootActions?

    private  lazy var settingsOnboarding = model.settingsMyProductsOnboarding
    private let model: Model
    private var bindings = Set<AnyCancellable>()
   
    
    init(navigationBar: NavigationBarView.ViewModel,
         totalMoney: MyProductsMoneyViewModel,
         productSections: [MyProductsSectionViewModel],
         openProductVM: MyProductsOpenProductView.ViewModel,
         editModeState: EditMode = .inactive,
         model: Model = .emptyMock,
         refreshingIndicator: RefreshingIndicatorView.ViewModel,
         showOnboarding: [Onboarding: Bool] = [:]) {

        self.model = model
        self.editModeState = editModeState
        self.navigationBar = navigationBar
        self.totalMoneyVM = totalMoney
        self.openProductVM = openProductVM
        self.sections = productSections
        self.refreshingIndicator = refreshingIndicator
        self.showOnboarding = showOnboarding
    }

    convenience init(_ model: Model) {

        self.init(navigationBar: .init(background: .mainColorsWhite),
                  totalMoney: .init(model: model),
                  productSections: [],
                  openProductVM: .init(model),
                  editModeState: .inactive,
                  model: model,
                  refreshingIndicator: .init(isActive: false),
                  showOnboarding: [:])
        
        updateNavBar(state: .normal)
        bind()
        bind(openProductVM)
    }

    private func bind() {

        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                
                case _ as MyProductsViewModelAction.Close.Link:
                    self.link = nil
                    
                case _ as MyProductsViewModelAction.Tapped.CancelExpandedCurrency:
                    
                    switch totalMoneyVM.currencyButtonVM.state {
                    case .expanded:
                        withAnimation {
                            totalMoneyVM.currencyButtonVM.state = .enabled
                        }
                    case .disabled, .enabled: break
                    }
                 
                case _ as MyProductsViewModelAction.PullToRefresh:
                    guard editModeState != .active else { return }
                    
                    model.action.send(ModelAction.Products.Update.Total.All())
                    self.action.send(MyProductsViewModelAction.StartIndicator())
                    
                case _ as MyProductsViewModelAction.StartIndicator:
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) { [unowned self] in
                        self.refreshingIndicator.isActive = !self.model.productsUpdating.value.isEmpty
                    }
                    
                case let payload as MyProductsViewModelAction.Tapped.EditMode:
                    
                    guard editModeState != .transient else { return }
                    
                    if  editModeState == .active  { //finished ordered mode
                        
                        self.editModeState = .inactive
                        updateNavBar(state: .normal)
                        
                        if !settingsOnboarding.isHideOnboardingShown {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                self.playHideOnboarding()
                            }
                        }
                        
                        if payload.needSave { //change Orders in Sections
                           
                            let newOrders = sections.reduce(into: [ProductType: [ProductData.ID]]()) { dict, sectionVM in
                                if let productType = ProductType(rawValue: sectionVM.id) {
                                    dict[productType] = sectionVM.items.compactMap { $0.itemVM?.id }
                                }
                            }
                            
                            guard !newOrders.isEmpty else { return }
                            model.action.send(ModelAction.Products.UpdateOrders(orders: newOrders))
                        
                        } else { //rollback ordered
                            
                            let updatedSections = Self.updateViewModel(with: model.products.value,
                                                                       sections: self.sections,
                                                                       productsOpening: model.productsOpening.value,
                                                                       model: model)
                            withAnimation {
                                sections = updatedSections
                            }
                            
                            bind(sections)
                        }
                        
                    } else { //start ordered mode
                        
                        sections.flatMap { $0.items }
                                .compactMap { $0.itemVM }
                                .filter { $0.sideButton != nil }
                                .forEach { $0.sideButton = nil }
                        
                        self.editModeState = .active
                        
                        if !self.settingsOnboarding.isOpenedReorder {
                            self.settingsOnboarding.isOpenedReorder = true
                            self.model.settingsMyProductsOnboardingUpdate(self.settingsOnboarding)
                        }
                       
                        if let isShow = showOnboarding[.ordered], isShow {
                            withAnimation { showOnboarding[.ordered] = false }
                        }
                        
                        updateNavBar(state: .orderedNotMove)
                    }
                    
                case _ as MyProductsViewModelAction.Tapped.NewProductLauncher:
                    bottomSheet = .init(type: .newProductLauncher(self.openProductVM))
                    
                default:
                    break
                }
        }.store(in: &bindings)
        
        model.products
            .combineLatest(model.productsOpening)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] data in
                
                let products = data.0
                let productsOpening = data.1
                
                let updatedSections = Self.updateViewModel(with: products,
                                                      sections: self.sections,
                                                      productsOpening: productsOpening,
                                                      model: model)
                bind(updatedSections)
                self.sections = updatedSections
                
        }.store(in: &bindings)
        
        model.productsUpdating
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] productsUpdating in
                
                if productsUpdating.isEmpty {
                    
                    self.refreshingIndicator.isActive = false
                }
                
        }.store(in: &bindings)
    
        model.productsOrdersUpdating
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] isOrdersUpdating in
               
                if isOrdersUpdating {
                    updateNavBar(state: .ordersModeDisable)
                    
                } else {
                    updateNavBar(state: .normal)
                }
            
        }.store(in: &bindings)
        
    }
    
    private func bind(_ sections: [MyProductsSectionViewModel]) {
        
        for section in sections {
            
            section.action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self]  action in
                    
                    switch action {
                    case _ as MyProductsSectionViewModelAction.Events.ItemMoved:
                        
                        updateNavBar(state: .orderedMoved)
                        
                    case let payload as MyProductsSectionViewModelAction.Events.ItemTapped:
                        
                        guard self.editModeState != .active,
                              let product = model.products.value.values
                                                .flatMap({ $0 })
                                                .first(where: { $0.id == payload.productId })
                        else { return }
                        
                        guard let productProfileViewModel = ProductProfileViewModel
                            .init(model,
                                  product: product,
                                  rootView: "\(type(of: self))")
                        else { return }
                        
                        productProfileViewModel.rootActions = rootActions
                        link = .productProfile(productProfileViewModel)
                        
                    default: break
                    }
           
            }.store(in: &bindings)
        } //for
    }
    
    private func bind(_ openProductVM: MyProductsOpenProductView.ViewModel) {
        
        openProductVM.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as MyProductsViewModelAction.Tapped.NewProduct:
                    
                    switch payload.productType {
                    case .account:
                        bottomSheet = nil
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                            
                            let accountProductsList = self.model.accountProductsList.value
                            
                            guard let openAccountViewModel: OpenAccountViewModel = .init(self.model, products: accountProductsList)
                            else { return }

                            self.bottomSheet = .init(type: .openAccount(openAccountViewModel))
                        }
                        
                    case .deposit:
                        bottomSheet = nil
                       
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                            let openDepositViewModel = OpenDepositViewModel(self.model,
                                                                            catalogType: .deposit,
                                                                            dismissAction: {[weak self] in
                                self?.action.send(MyProductsViewModelAction.Close.Link()) })
                            
                            self.link = .openDeposit(openDepositViewModel)
                        }
                        
                    case .card:
                        bottomSheet = nil
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                            let authProductsViewModel = AuthProductsViewModel(self.model,
                                                                              products: self.model.catalogProducts.value,
                                                                              dismissAction: { [weak self] in
                                self?.action.send(MyProductsViewModelAction.Close.Link()) })
                            
                            self.link = .openCard(authProductsViewModel)
                        }
                        
                    default: bottomSheet = nil
                    }
                    
                default: break
                }
                
        }.store(in: &bindings)
    }
    
    static func updateViewModel(with products: ProductsData,
                                sections: [MyProductsSectionViewModel],
                                productsOpening: Set<ProductType>,
                                model: Model) -> [MyProductsSectionViewModel]  {
        
        var updatedSections = [MyProductsSectionViewModel]()
        
        for productType in ProductType.allCases {
            
            let productsForType = products[productType]
            
            if let section = sections.first(where: { $0.id == productType.rawValue }) {
                
                section.update(with: productsForType, productsOpening: productsOpening)
                    
                guard !section.items.isEmpty else { continue }
                updatedSections.append(section)
                
            } else {
                
                guard let section = MyProductsSectionViewModel(productType: productType,
                                                               products: productsForType,
                                                               settings: model.settingsProductsSections,
                                                               model: model)
                else { continue }
                updatedSections.append(section)
            }
        }
        
        return updatedSections
    }
    
    @MainActor
    func startOnboarding() {
        
        if !settingsOnboarding.isOpenedView {
            
            Task {
                
                withAnimation { showOnboarding[.ordered] = true }
                
                settingsOnboarding.isOpenedView = true
                model.settingsMyProductsOnboardingUpdate(settingsOnboarding)
                
                try await Task.sleep(nanoseconds: .seconds(5))

                if let isShow = showOnboarding[.ordered], isShow  {
                    withAnimation { showOnboarding[.ordered] = false }
                    updateNavBar(state: .normal)
                }
                
                if editModeState != .active {
                    updateNavBar(state: .normal)
                }

                try await Task.sleep(nanoseconds: .seconds(2))
                playHideOnboarding()
            }
  
        } else {
            
            playHideOnboarding()
        }
        
    }
    
    @MainActor
    private func playHideOnboarding() {
       
        guard !settingsOnboarding.isHideOnboardingShown && editModeState != .active
        else { return }
        
        Task {
            
            withAnimation { showOnboarding[.hide] = true }
            
            settingsOnboarding.isHideOnboardingShown = true
            model.settingsMyProductsOnboardingUpdate(settingsOnboarding)
            
            try await Task.sleep(nanoseconds: .seconds(5))
            
            withAnimation { showOnboarding[.hide] = false }
        }

    }
    
    func updateNavBar(state: NavBarState) {
        
        let title: String
        let leftButton: NavigationBarView.ViewModel.ItemViewModel
        let rightButton: NavigationBarView.ViewModel.ButtonMarkedItemViewModel
        
        switch state {
        case .normal:
            
            title = "Мои продукты"
            leftButton = NavigationBarView.ViewModel.BackButtonItemViewModel(icon: .ic24ChevronLeft, action: {})
            rightButton =  .init(icon: .ic24BarInOrder, isDisabled: false,
                                 action: { [weak self] in
                                            self?.action.send(MyProductsViewModelAction.Tapped.EditMode(needSave: true)) })
        
        case .ordersModeDisable:
            
            title = "Мои продукты"
            leftButton = NavigationBarView.ViewModel.BackButtonItemViewModel(icon: .ic24ChevronLeft, action: {})
            rightButton =  .init(icon: .ic24BarInOrder, isDisabled: true,
                                 action: { [weak self] in
                                            self?.action.send(MyProductsViewModelAction.Tapped.EditMode(needSave: true)) })
            
        case .orderedNotMove:
            
            title = "Последовательность"
            leftButton = NavigationBarView.ViewModel.ButtonItemViewModel
                .init(icon: .ic24Close, action: { [weak self] in
                    self?.action.send(MyProductsViewModelAction.Tapped.EditMode(needSave: false)) })

            rightButton =  .init(icon: .ic24Check, isDisabled: true,
                                 action: { [weak self] in
                                            self?.action.send(MyProductsViewModelAction.Tapped.EditMode(needSave: true)) })
            
        case .orderedMoved:
            
            title = "Последовательность"
            leftButton = NavigationBarView.ViewModel.ButtonItemViewModel
                .init(icon: .ic24Close, action: { [weak self] in
                    self?.action.send(MyProductsViewModelAction.Tapped.EditMode(needSave: false)) })

            rightButton =  .init(icon: .ic24Check,
                                 isDisabled: false,
                                 action: { [weak self] in
                                            self?.action.send(MyProductsViewModelAction.Tapped.EditMode(needSave: true)) })
        }
        
        if !settingsOnboarding.isOpenedView {
        
            rightButton.markedDot = .init(isBlinking: true) 
        
        } else {
            
            if !settingsOnboarding.isOpenedReorder {
                rightButton.markedDot = .init(isBlinking: false)
                
            } else {
                rightButton.markedDot = nil
            }
        }
        
        self.navigationBar.title = title
        self.navigationBar.rightItems = [ rightButton ]
        self.navigationBar.leftItems = [ leftButton ]
    }
    
}

extension MyProductsViewModel {
    
    enum Onboarding: Int {
        case ordered
        case hide

        var playerVM: OnboardingPlayerView.ViewModel? {
            switch self {
            case .ordered: return .init(onboardingName: "MyProductsOrdered3x")
            case .hide: return .init(onboardingName: "MyProductsHide3x")
            }
        }
    }
    
    enum Link {
        
        case openCard(AuthProductsViewModel)
        case openDeposit(OpenDepositViewModel)
        case productProfile(ProductProfileViewModel)
    }
    
    enum NavBarState {
        case normal
        case orderedNotMove
        case orderedMoved
        case ordersModeDisable
    }
    
    struct BottomSheet: BottomSheetCustomizable {

        let id = UUID()
        let type: BottomSheetType

        enum BottomSheetType {

            case openAccount(OpenAccountViewModel)
            case newProductLauncher(MyProductsOpenProductView.ViewModel)
        }
    }
}

enum MyProductsViewModelAction {
    
    enum Tapped {
    
        struct Product: Action {
            let productId: ProductData.ID
        }
        
        struct NewProduct: Action {
            let productType: ProductType
        }
        
        struct NewProductLauncher: Action {}
        
        struct CancelExpandedCurrency: Action {}
        
        struct EditMode: Action {
            let needSave: Bool
        }
    }
    
    enum Close {
     
        struct Link: Action {}
    }
    
    struct PullToRefresh: Action {}
    
    struct StartIndicator: Action {}
    
    struct StartOnboarding: Action {}
    
}

extension MyProductsViewModel {
    
    static let sample = MyProductsViewModel(
            navigationBar: .init(
            title: "Мои продукты",
            leftItems: [NavigationBarView.ViewModel.BackButtonItemViewModel(icon: .ic24ChevronLeft, action: {})],
            rightItems: [NavigationBarView.ViewModel.ButtonItemViewModel(icon: .ic24BarInOrder, action: {})],
            background: .mainColorsWhite),
            totalMoney: .sampleBalance,
            productSections: [.sample2, .sample3],
            openProductVM: .previewSample,
            refreshingIndicator: .init(isActive: true)
    )
    
    static let sampleOpenProduct = MyProductsViewModel(
            navigationBar: .init(
            title: "Мои продукты",
            leftItems: [NavigationBarView.ViewModel.BackButtonItemViewModel(icon: .ic24ChevronLeft, action: {})],
            rightItems: [NavigationBarView.ViewModel.ButtonItemViewModel(icon: .ic24Edit, action: { })],
            background: .mainColorsWhite),
            totalMoney: .sampleBalance,
            productSections: [.sample2, .sample3],
            openProductVM: .previewSample,
            refreshingIndicator: .init(isActive: true),
            showOnboarding: [.hide: true, .ordered: false]
    )
}

