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
    
    @Published var productViewModel: ProductProfileCardView.ViewModel
    @Published var buttonsViewModel: ProductProfileButtonsSectionView.ViewModel
    @Published var accountDetailViewModel: ProductProfileAccountDetailView.ViewModel?
    @Published var historyViewModel: ProductProfileHistoryView.ViewModel?
    @Published var alert: Alert.ViewModel?
    @Published var detailOperation: OperationDetailViewModel?
    @Published var isPresentedSheet: Bool
    
    private let model: Model
    private var bindings = Set<AnyCancellable>()
    
    internal init(productViewModel: ProductProfileCardView.ViewModel, model: Model) {
        
        self.model = model
        self.productViewModel = productViewModel
        self.isPresentedSheet = false
        self.accountDetailViewModel = nil
        
        self.buttonsViewModel = .init(kind: productViewModel.product.productType)
        self.historyViewModel = .init(model, productId: productViewModel.product.id, productType: productViewModel.product.productType)
        
        setupHistoryView()
        bind()
    }
    
    func bind() {
        
        buttonsViewModel.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                switch action {
                case _ as ProductProfileViewModelAction.CustomName:
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
        
        historyViewModel?.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                switch action {
                    
                case let statement as HistoryViewModelAction.DetailTapped.Detail:
                    
                    if let product = model.products.value[productViewModel.product.productType]?.first(where: {$0.id == productViewModel.product.id}), let details =
                        model.statement.value.productStatement[product.id]?.first(where: {$0.operationId == statement.statement}) {
                        
                        withAnimation(.linear(duration: 0.3)) {
                            
                            detailOperation = .init(productStatement: details, product: product, model: self.model)
                            isPresentedSheet = true
                        }
                    }
                default:
                    break
                }
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
