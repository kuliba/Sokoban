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
    
    @Published var productViewModel: ProductProfileCardView.ViewModel
    @Published var buttonsViewModel: ProductProfileButtonsSectionView.ViewModel
    @Published var accountDetailViewModel: ProductProfileAccountDetailView.ViewModel?
    @Published var historyViewModel: ProductProfileHistoryView.ViewModel?
    @Published var alert: Alert.ViewModel?
    @Published var detailOperation: OperationDetailViewModel?
    let dismissAction: () -> Void
    
    private let model: Model
    private var bindings = Set<AnyCancellable>()
    
    internal init(productViewModel: ProductProfileCardView.ViewModel, model: Model, dismissAction: @escaping () -> Void) {
        
        self.model = model
        self.productViewModel = productViewModel

        self.accountDetailViewModel = nil
        
        self.buttonsViewModel = .init(kind: productViewModel.product.productType)
        self.historyViewModel = .init(model, productId: productViewModel.product.id, productType: productViewModel.product.productType)
        
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
        self.dismissAction = dismissAction
        
        bind()
    }
    
    func bind() {
        action
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
                case _ as ProductProfileViewModelAction.DetailOperation:
                    break
                default:
                    break
                }
            }.store(in: &bindings)
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
}
