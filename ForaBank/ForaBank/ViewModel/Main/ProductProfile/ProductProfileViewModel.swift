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
    @Published var selector: ProductProfileButtonsSectionView.ViewModel
    @Published var detail: ProductProfileAccountDetailView.ViewModel?
    @Published var history: ProductProfileHistoryView.ViewModel?
    @Published var alert: Alert.ViewModel?
    @Published var operationDetail: OperationDetailViewModel?
    @Published var accentColor: Color

    private let model: Model
    private var bindings = Set<AnyCancellable>()
    
    init(statusBar: StatusBarViewModel, product: ProductProfileCardView.ViewModel, selector: ProductProfileButtonsSectionView.ViewModel, detail: ProductProfileAccountDetailView.ViewModel?, history: ProductProfileHistoryView.ViewModel?, alert: Alert.ViewModel? = nil, operationDetail: OperationDetailViewModel? = nil, accentColor: Color = .purple, model: Model = .emptyMock) {
        
        self.statusBar = statusBar
        self.product = product
        self.selector = selector
        self.detail = detail
        self.history = history
        self.alert = alert
        self.operationDetail = operationDetail
        self.accentColor = accentColor
        self.model = model
    }
    
    init?(_ model: Model, productData: ProductData, dismissAction: @escaping () -> Void) {
        
        guard let productViewModel = ProductProfileCardView.ViewModel(model, productData: productData) else {
            return nil
        }
        self.statusBar = ProductProfileViewModel.StatusBarViewModel(backButton: .init(icon: .ic24ChevronLeft, action: dismissAction), title: "Platinum", subtitle: "· 4329", actionButton: .init(icon: .ic24Edit2, action: {}), color: .iconBlack)
        self.product = productViewModel
        self.selector = .init(kind: productData.productType)
        self.history = .init(model, productId: productData.id, productType: productData.productType)
        self.accentColor = .purple
        self.model = model
        
        bind()
    }
    
    func bind() {
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                switch action {
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
        
        product.$active
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] active in
                
                guard let productViewModel = product.products.first(where: { $0.id == active }) else {
                    return
                }
                
                statusBar.title = productViewModel.name
                statusBar.subtitle = productViewModel.header.number ?? ""
                statusBar.color = productViewModel.appearance.textColor
                accentColor = productViewModel.appearance.background.color
                
            }.store(in: &bindings)
        
    }
    
    func setupHistoryView() {
        
        switch productViewModel.product.productType {
        case .card:
            break
        case .account:
            break
        case .deposit:
            break
        case .loan:
            self.historyViewModel = nil
        }
        
        if let statement = model.statement.value.productStatement[productViewModel.product.id], let historyViewModel = historyViewModel {
            
            historyViewModel.listState = .list(historyViewModel.separationDate(operations: statement))
            historyViewModel.dateOperations = historyViewModel.separationDate(operations: statement)
            
            if historyViewModel.sumDeifferentGroup(operations: statement).count > 0 {
                
                self.historyViewModel?.spendingViewModel = .init(value: historyViewModel.sumDeifferentGroup(operations: statement))
            }
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
        @Published var color: Color
        
        init(backButton: ButtonViewModel, title: String, subtitle: String, actionButton: ButtonViewModel?, color: Color = .iconWhite) {
            
            self.backButton = backButton
            self.title = title
            self.subtitle = subtitle
            self.actionButton = actionButton
            self.color = color
        }
        
        struct ButtonViewModel {
            
            let icon: Image
            let action: () -> Void
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
}
