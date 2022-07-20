//
//  ProductProfileViewModel.swift
//  ForaBank
//
//  Created by Дмитрий on 09.03.2022.
//

import Foundation
import Combine
import SwiftUI

class ProductProfileViewModel: ObservableObject {
    
    let action: PassthroughSubject<Action, Never> = .init()
    
    let navigationBar: NavigationBarView.ViewModel
    @Published var product: ProductProfileCardView.ViewModel
    @Published var buttons: ProductProfileButtonsView.ViewModel
    @Published var detail: ProductProfileDetailView.ViewModel?
    @Published var history: ProductProfileHistoryView.ViewModel?
    @Published var alert: Alert.ViewModel?
    @Published var operationDetail: OperationDetailViewModel?
    @Published var accentColor: Color
    @Published var bottomSheet: BottomSheet?
    @Published var link: Link? { didSet { isLinkActive = link != nil } }
    @Published var isLinkActive: Bool = false
    @Published var sheet: Sheet?
    @Published var textFieldAlert: AlertTextFieldView.ViewModel?

    var rootActions: RootViewModel.RootActions?
    
    private var historyPool: [ProductData.ID : ProductProfileHistoryView.ViewModel]
    private let model: Model
    private var bindings = Set<AnyCancellable>()
    
    private var productData: ProductData? {
        model.products.value.values.flatMap({ $0 }).first(where: { $0.id == self.product.activeProductId })
    }
    
    init(navigationBar: NavigationBarView.ViewModel,product: ProductProfileCardView.ViewModel, buttons: ProductProfileButtonsView.ViewModel, detail: ProductProfileDetailView.ViewModel?, history: ProductProfileHistoryView.ViewModel?, alert: Alert.ViewModel? = nil, operationDetail: OperationDetailViewModel? = nil, accentColor: Color = .purple, historyPool: [ProductData.ID : ProductProfileHistoryView.ViewModel] = [:] , model: Model = .emptyMock) {
        
        self.navigationBar = navigationBar
        self.product = product
        self.buttons = buttons
        self.detail = detail
        self.history = history
        self.alert = alert
        self.operationDetail = operationDetail
        self.accentColor = accentColor
        self.historyPool = historyPool
        self.model = model
    }
    
    init?(_ model: Model, product: ProductData, dismissAction: @escaping () -> Void) {
        
        guard let productViewModel = ProductProfileCardView.ViewModel(model, productData: product) else {
            return nil
        }
        
        // status bar
        self.navigationBar = .init(product: product, dismissAction: dismissAction)
        self.product = productViewModel
        self.buttons = .init(with: product)
        self.accentColor = Self.accentColor(with: product)
        self.historyPool = [:]
        self.model = model
        
        // detail view model
        self.detail = makeDetailViewModel(with: product)
        
        // history view model
        let historyViewModel = makeHistoryViewModel(productType: product.productType, productId: product.id, model: model)
        self.history = historyViewModel
        self.historyPool[product.id] = historyViewModel
        bind(history: historyViewModel)
        bind(buttons: buttons)

        bind()
    }
    
    func bind() {
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                switch action {
                case _ as ProductProfileViewModelAction.PullToRefresh:
                    model.action.send(ModelAction.Products.Update.Fast.Single.Request(productId: product.activeProductId))
                    model.action.send(ModelAction.Statement.List.Request(productId: product.activeProductId, direction: .latest))
                    if product.productType == .loan {
                        
                        model.action.send(ModelAction.Loans.Update.Single.Request(productId: product.activeProductId))
                    }
                    
                case let payload as ProductProfileViewModelAction.OptionsPannel.Show:
                    bind(optionsPannel: payload.viewModel)
                    bottomSheet = .init(type: .optionsPannel(payload.viewModel))
                    
                case _ as ProductProfileViewModelAction.OptionsPannel.Close:
                    bottomSheet = nil
                    
                case _ as ProductProfileViewModelAction.Link.Close:
                    link = nil
                    
                case _ as ProductProfileViewModelAction.Alert.Close:
                    alert = nil
                    
                case _ as ProductProfileViewModelAction.ActivateCard:
                    alert = .init(title: "Активировать карту?", message: "После активации карта будет готова к использованию", primary: .init(type: .default, title: "Отмена", action: { [weak self] in
                        self?.alert = nil
                    }), secondary: .init(type: .default, title: "Ok", action: { [weak self] in
                        self?.model.action.send(ModelAction.Card.Block.Request(cardId: 1))
                        self?.alert = nil
                    }))
                    
                case _ as ProductProfileViewModelAction.BlockProduct:
                    alert = .init(title: "Заблокировать карту?", message: "Карту можно будет разблокироать в приложении или в колл-центре", primary: .init(type: .default, title: "Отмена", action: { [weak self] in
                        self?.alert = nil
                    }), secondary: .init(type: .default, title: "Ok", action: { [weak self] in
                        self?.model.action.send(ModelAction.Card.Unblock.Request(cardId: 1))
                        self?.alert = nil
                    }))
                case _ as ProductProfileViewModelAction.Link.PlacesMap:
                    guard let placesViewModel = PlacesViewModel(model) else {
                        return
                    }
                    sheet = .init(type: .placesMap(placesViewModel))
                
                case let payload as ProductProfileViewModelAction.CustomName:
                    
                    textFieldAlert = customNameAlert(for: payload.productType, alertTitle: payload.alertTitle)
                    
                case _ as ProductProfileViewModelAction.CloseTextFieldAlert:
                    textFieldAlert = nil
                    
                default:
                    break
                }
            }.store(in: &bindings)
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in

                switch action {

                case let payload as ModelAction.Products.UpdateCustomName.Response:

                    switch payload {

                    case .complete(productId: let productId, name: let name):
                        
                        
                        guard let product = model.products.value.values.flatMap({ $0 }).first(where: { $0.id == productId }) else {
                            return
                        }
                        
                        withAnimation {
                            
                            navigationBar.updateName(with: name)
                            accentColor = Self.accentColor(with: product)
                        }

                    case .failed(message: let message):
                        alert = .init(title: "Ошибка", message: message, primary: .init(type: .default, title: "Ok", action: { [weak self] in
                            self?.alert = nil
                        }))
                    }

                    default: break
                }
            }.store(in: &bindings)
        
        model.loans
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] loans in
                
                guard product.productType == .loan else {
                   return
                }
                
                if let productLoan = model.products.value[.loan]?.first(where: { $0.id == product.activeProductId }) as? ProductLoanData,
                   let loanData = loans.first(where: { $0.loandId == product.activeProductId}) {
                    
                    withAnimation {
                        
                        if let detail = detail {
                            
                            detail.update(productLoan: productLoan, loanData: loanData, model: model)
                            
                        } else {
                            
                            detail = .init(productLoan: productLoan, loanData: loanData, model: model)
                        }
                    }
                    
                } else {
                    
                    withAnimation {
                        detail = nil
                    }
                }
 
            }.store(in: &bindings)
        
        product.$activeProductId
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] activeProductId in
                
                guard let product = model.products.value.values.flatMap({ $0 }).first(where: { $0.id == activeProductId }) else {
                    return
                }
                
                // status bar update
                withAnimation {
                    
                    navigationBar.update(with: product)
                    accentColor = Self.accentColor(with: product)
                }
                
                // buttons update
                withAnimation {
                    buttons.update(with: product)
                }
                
                bind(buttons: buttons)
                
                // detail update
                withAnimation {
                    detail = makeDetailViewModel(with: product)
                }
                
                // history update
                if let historyViewModel = historyPool[activeProductId] {
                    
                    withAnimation {
                        history = historyViewModel
                    }
                    
                } else {
                    
                    let historyViewModel = makeHistoryViewModel(productType: product.productType, productId: activeProductId, model: model)

                    withAnimation {
                        history = historyViewModel
                    }
                    
                    historyPool[activeProductId] = historyViewModel
                    bind(history: historyViewModel)
                }
                
                if product.productType == .card || product.productType == .account {
                    
                    guard let alertTitle = alertTitle(for: product.productType) else { return }
                    
                    withAnimation {
                        
                        navigationBar.rightButtons = [.init(icon: .ic16Edit2, action: { [weak self] in
                            
                            self?.action.send(ProductProfileViewModelAction.CustomName(productId: product.id, productType: product.productType, alertTitle: alertTitle))
                        })]
                    }
                } else {
                    
                    withAnimation {
                        
                        navigationBar.rightButtons = []
                    }
                }
                
            }.store(in: &bindings)
    }
    
    func bind(history: ProductProfileHistoryView.ViewModel?) {
           
        guard let history = history else {
            return
        }
           history.action
               .receive(on: DispatchQueue.main)
               .sink { [weak self] action in
                   
                   guard let self = self else { return }
                   
                   switch action {
                   case let payload as ProductProfileHistoryViewModelAction.DidTapped.Detail:
                       guard let storage = self.model.statements.value[self.product.activeProductId],
                             let statementData = storage.statements.first(where: { $0.id == payload.statementId }),
                             let productData = self.model.products.value.values.flatMap({ $0 }).first(where: { $0.id == self.product.activeProductId }),
                             let operationDetailViewModel = OperationDetailViewModel(productStatement: statementData, product: productData, model: self.model) else {
                           
                           return
                       }
                       
                       self.bottomSheet = .init(type: .operationDetail(operationDetailViewModel))
                       
                   default:
                       break
                   }
                   
               }.store(in: &bindings)
       }
    
    func bind(buttons: ProductProfileButtonsView.ViewModel) {
        
        buttons.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as ProductProfileButtonsSectionViewAction.ButtonDidTapped:
                    
                    switch payload.buttonType {
                    case .topLeft:
                        let optionsPannelViewModel = ProductProfileOptionsPannelView.ViewModel(title: "Пополнить", buttonsTypes: [.refillFromOtherBank, .refillFromOtherProduct], productType: product.productType)
                        self.action.send(ProductProfileViewModelAction.OptionsPannel.Show(viewModel: optionsPannelViewModel))
                        
                    case .topRight:
                        switch product.productType {
                        case .card, .account:
                            rootActions?.dismissAll()
                            rootActions?.switchTab(.payments)
                            
                        case .deposit:
                            guard let depositProduct = self.model.products.value.values.flatMap({ $0 }).first(where: { $0.id == self.product.activeProductId }) as? ProductDepositData,
                                    let balance = depositProduct.balance else {
                                return
                            }
                            
                            let meToMeViewModel = MeToMeViewModel(type: .transferDeposit(depositProduct, balance), closeAction: {})
                            self.bottomSheet = .init(type: .meToMe(meToMeViewModel))
                            
                        default:
                            break
                        }
                        
                       
                    case .bottomLeft:
                        switch product.productType {
                        case .deposit:
                            let optionsPannelViewModel = ProductProfileOptionsPannelView.ViewModel(buttonsTypes: [.requisites, .statement, .info, .conditions], productType: product.productType)
                            self.action.send(ProductProfileViewModelAction.OptionsPannel.Show(viewModel: optionsPannelViewModel))
                            
                        default:
                            let optionsPannelViewModel = ProductProfileOptionsPannelView.ViewModel(buttonsTypes: [.requisites, .statement], productType: product.productType)
                            self.action.send(ProductProfileViewModelAction.OptionsPannel.Show(viewModel: optionsPannelViewModel))
                            
                        }
                        
                    case .bottomRight:
                        
                        switch product.productType {
                        case .card:
                            print("block/unblock")
                            
                        case .account:
                            print("disabled")
                            
                        case .deposit:
                            let optionsPannelViewModel = ProductProfileOptionsPannelView.ViewModel(buttonsTypes: [.closeDeposit], productType: product.productType)
                            self.action.send(ProductProfileViewModelAction.OptionsPannel.Show(viewModel: optionsPannelViewModel))
                            
                        case .loan:
                            let optionsPannelViewModel = ProductProfileOptionsPannelView.ViewModel(buttonsTypes: [.refillFromOtherBank, .refillFromOtherProduct], productType: product.productType)
                            self.action.send(ProductProfileViewModelAction.OptionsPannel.Show(viewModel: optionsPannelViewModel))
                        }
                    }

                default:
                    break
                }
                
            }.store(in: &bindings)
    }
    
    func bind(optionsPannel: ProductProfileOptionsPannelView.ViewModel) {
        
        optionsPannel.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                self.action.send(ProductProfileViewModelAction.OptionsPannel.Close())
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                    
                    guard let productData = self.productData else {
                        return
                    }
                    
                    switch action {
                    case let payload as ProductProfileOptionsPannelViewModelAction.ButtonTapped:
                        switch payload.buttonType {
                        case .requisites:
                            let productInfoViewModel = InfoProductViewModel(model: self.model, product: productData, info: false)
                            self.link = .productInfo(productInfoViewModel)
                            
                        case .info:
                            let productInfoViewModel = InfoProductViewModel(model: self.model, product: productData, info: true)
                            self.link = .productInfo(productInfoViewModel)
                            
                        case .statement:
                            let productStatementViewModel = ProductStatementViewModel(product: productData, closeAction: { [weak self] in self?.action.send(ProductProfileViewModelAction.Link.Close())})
                            self.link = .productStatement(productStatementViewModel)
                            
                        case .refillFromOtherProduct:
                            let meToMeViewModel = MeToMeViewModel(type: .refill(productData), closeAction: {})
                            self.bottomSheet = .init(type: .meToMe(meToMeViewModel))
                            
                        case .refillFromOtherBank:
                            let meToMeExternalViewModel = MeToMeExternalViewModel(productTo: productData, closeAction: { [weak self] in self?.action.send(ProductProfileViewModelAction.Link.Close())})
                            self.link = .meToMeExternal(meToMeExternalViewModel)
                            
                        case .conditions:
                            let printFormViewModel = PrintFormView.ViewModel(type: .deposit(depositId: productData.id), model: self.model)
                            self.sheet = .init(type: .printForm(printFormViewModel))
                        
                        case .closeDeposit:
                            let alertViewModel = Alert.ViewModel(title: "Закрыть вклад",
                                                                 message: "Срок вашего вклада еще не истек. Для досрочного закрытия обратитесь в ближайший офис",
                                                                 primary: .init(type: .default, title: "Наши офисы", action: { [weak self] in self?.action.send(ProductProfileViewModelAction.Link.PlacesMap())}),
                                                                 secondary: .init(type: .default, title: "Ок", action: { [weak self] in self?.action.send(ProductProfileViewModelAction.Alert.Close())}))
                            self.alert = .init(alertViewModel)
                        }
                        
                    default:
                        break
                    }
                    
                }
                
            }.store(in: &bindings)
    }

    func customNameAlert(for productType: ProductType, alertTitle: String) ->  AlertTextFieldView.ViewModel? {
        
        let textFieldAlert: AlertTextFieldView.ViewModel = .init(
            title: alertTitle,
            message: nil,
            maxLength: 15,
            primary: .init(type: .default,
                           title: "Ок",
                           action: { [weak self] text in
                               self?.action.send(ProductProfileViewModelAction.CloseTextFieldAlert())
                               if let text = text, let product = self?.product {
                                   
                                   self?.model.action.send(ModelAction.Products.UpdateCustomName.Request(productId: product.activeProductId, productType: product.productType, name: text))
                               }
                           }),
            secondary: .init(type: .cancel,
                             title: "Отмена",
                             action: { [weak self] _ in
                                 
                                 self?.action.send(ProductProfileViewModelAction.CloseTextFieldAlert())
                             }))
        
        return textFieldAlert
    }
    
    func alertTitle(for productType: ProductType) -> String? {
        
        switch productType {
        case .card: return "Название карты"
        case .account: return "Название счета"
        default: return nil
        }
    }

    func makeHistoryViewModel(productType: ProductType, productId: ProductData.ID, model: Model) -> ProductProfileHistoryView.ViewModel? {
    
        guard productType != .loan else {
            return nil
        }
        
        return ProductProfileHistoryView.ViewModel(model, productId: productId)
    }
    
    static func accentColor(with product: ProductData) -> Color {
        
        return product.backgroundColor
    }
    
    func makeDetailViewModel(with product: ProductData) -> ProductProfileDetailView.ViewModel? {
        
        switch product {
        case let productCard as ProductCardData:
            return .init(productCard: productCard, model: model)
            
        case let productLoan as ProductLoanData:
            guard let loanData = model.loans.value.first(where: { $0.loandId == productLoan.id }) else {
                return nil
            }
            
            return .init(productLoan: productLoan, loanData: loanData, model: model)
            
        default:
            return nil
        }
    }
}

fileprivate extension NavigationBarView.ViewModel {
    
    convenience init(product: ProductData, dismissAction: @escaping () -> Void, rightButtons: [ButtonViewModel] = []) {
        self.init(
            title: Self.title(with: product),
            subtitle: Self.subtitle(with: product),
            leftButtons: [BackButtonViewModel(icon: .ic24ChevronLeft, action: dismissAction)],
            rightButtons: rightButtons,
            background: Self.accentColor(with: product),
            foreground: Self.textColor(with: product),
            contrast: 0.5)
    }
    
    static func title(with productData: ProductData) -> String {
        
        return productData.displayName
    }
    
    static func subtitle(with productData: ProductData) -> String {
        
        guard let number = productData.displayNumber else {
            return ""
        }
        
        switch productData {
        case let productLoan as ProductLoanData:
            if let rate = NumberFormatter.persent.string(from: NSNumber(value: productLoan.currentInterestRate / 100)) {
                
                return "· \(number) · \(rate)"
                
            } else {
                
                return "· \(number)"
            }
            
        default:
            return "· \(number)"
        }
    }
    
    static func textColor(with product: ProductData) -> Color {
        
        return product.fontDesignColor.color
    }
    
    static func accentColor(with product: ProductData) -> Color {
        
        return product.backgroundColor
    }
    
    func update(with product: ProductData) {
        
        self.title = Self.title(with: product)
        self.subtitle = Self.subtitle(with: product)
        self.foreground = Self.textColor(with: product)
        self.background = Self.accentColor(with: product)
    }
    
    func updateName(with name: String) {
        self.title = name
    }
}

//MARK: - Types

extension ProductProfileViewModel {
    
    struct BottomSheet: BottomSheetCustomizable {

        let id = UUID()
        let type: Kind
        
        var keyboardOfssetMultiplier: CGFloat {
            switch type {
            case .meToMe: return 0
            default: return 0.6
            }
        }
        
        enum Kind {
            
            case operationDetail(OperationDetailViewModel)
            case optionsPannel(ProductProfileOptionsPannelView.ViewModel)
            case meToMe(MeToMeViewModel)
        }
    }
    
    enum Link {
        
        case productInfo(InfoProductViewModel)
        case productStatement(ProductStatementViewModel)
        case meToMeExternal(MeToMeExternalViewModel)
    }
    
    struct Sheet: Identifiable {
        
        let id = UUID()
        let type: Kind
        
        enum Kind {
            
            case printForm(PrintFormView.ViewModel)
            case placesMap(PlacesViewModel)
        }
    }
}

//MARK: - Action

enum ProductProfileViewModelAction {
    
    struct CustomName: Action {
        
        let productId: ProductData.ID
        let productType: ProductType
        let alertTitle: String
    }
    
    struct ActivateCard: Action {
        
        let productId: Int
    }
    
    struct BlockProduct: Action {
        
        let productId: Int
    }
    
    struct DetailOperation: Action {}
    
    struct Dismiss: Action {}
    
    struct ProductDetail: Action {
        
        let productId: Int
    }
    
    struct PullToRefresh: Action {}
    
    enum OptionsPannel {
        
        struct Show: Action {
            
            let viewModel: ProductProfileOptionsPannelView.ViewModel
        }
        
        struct Close: Action {}
    }
    
    enum Link {

        struct ShowProductInfo: Action {
            
            let viewModel: InfoProductViewModel
        }
        
        struct PlacesMap: Action {}
        
        struct Close: Action {}
    }
    
    enum Alert {

        struct Close: Action {}
    }
    
    struct CloseTextFieldAlert: Action {}
}
