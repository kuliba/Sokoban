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
    
    let statusBar: StatusBarViewModel
    @Published var product: ProductProfileCardView.ViewModel
    @Published var buttons: ProductProfileButtonsView.ViewModel
    @Published var detail: ProductProfileDetailView.ViewModel?
    @Published var history: ProductProfileHistoryView.ViewModel?
    @Published var alert: Alert.ViewModel?
    @Published var operationDetail: OperationDetailViewModel?
    @Published var accentColor: Color
    @Published var sheet: Sheet?

    private var historyPool: [ProductData.ID : ProductProfileHistoryView.ViewModel]
    private let model: Model
    private var bindings = Set<AnyCancellable>()
    
    init(statusBar: StatusBarViewModel, product: ProductProfileCardView.ViewModel, buttons: ProductProfileButtonsView.ViewModel, detail: ProductProfileDetailView.ViewModel?, history: ProductProfileHistoryView.ViewModel?, alert: Alert.ViewModel? = nil, operationDetail: OperationDetailViewModel? = nil, accentColor: Color = .purple, historyPool: [ProductData.ID : ProductProfileHistoryView.ViewModel] = [:] , model: Model = .emptyMock) {
        
        self.statusBar = statusBar
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
        let statusBarTitle = Self.statusBarTitle(with: product)
        let statusBarSubtitle = Self.statusBarSubtitle(with: product)
        let statusBarTextColor = Self.statusBarTextColor(with: product)
        self.statusBar = ProductProfileViewModel.StatusBarViewModel(backButton: .init(icon: .ic24ChevronLeft, action: dismissAction), title: statusBarTitle, subtitle: statusBarSubtitle, actionButton: .init(icon: .ic24Edit2, action: {}), textColor: statusBarTextColor)
        
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
                    
                default:
                    break
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
                    
                    statusBar.title = Self.statusBarTitle(with: product)
                    statusBar.subtitle = Self.statusBarSubtitle(with: product)
                    statusBar.textColor = Self.statusBarTextColor(with: product)
                    accentColor = Self.accentColor(with: product)
                }
                
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
                       
                       self.sheet = .init(type: .operationDetail(operationDetailViewModel))
                       
                   default:
                       break
                   }
                   
               }.store(in: &bindings)
       }
    
    func makeHistoryViewModel(productType: ProductType, productId: ProductData.ID, model: Model) -> ProductProfileHistoryView.ViewModel? {
    
        guard productType != .loan else {
            return nil
        }
        
        return ProductProfileHistoryView.ViewModel(model, productId: productId)
    }
    
    static func statusBarTitle(with productData: ProductData) -> String {
        
        return productData.displayName
    }
    
    static func statusBarSubtitle(with productData: ProductData) -> String {
        
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
    
    static func statusBarTextColor(with product: ProductData) -> Color {
        
        return product.fontDesignColor.color
    }
    
    static func accentColor(with product: ProductData) -> Color {
        
        return product.background.first?.color ?? .mainColorsBlackMedium
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

//MARK: - Types

extension ProductProfileViewModel {
    
    class StatusBarViewModel: ObservableObject {

        let backButton: ButtonViewModel
        @Published var title: String
        @Published var subtitle: String
        @Published var actionButton: ButtonViewModel?
        @Published var textColor: Color
        
        init(backButton: ButtonViewModel, title: String, subtitle: String, actionButton: ButtonViewModel?, textColor: Color = .iconWhite) {
            
            self.backButton = backButton
            self.title = title
            self.subtitle = subtitle
            self.actionButton = actionButton
            self.textColor = textColor
        }
        
        struct ButtonViewModel {
            
            let icon: Image
            let action: () -> Void
        }
    }
    
    struct Sheet: Identifiable {
        
        let id = UUID()
        let type: Kind
        
        enum Kind {
            
            case operationDetail(OperationDetailViewModel)
        }
    }
}

//MARK: - Action

enum ProductProfileViewModelAction {
    
    struct CustomName: Action {}
    
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
}
