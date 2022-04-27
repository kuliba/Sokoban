//
//  ProfileViewModel.swift
//  ForaBank
//
//  Created by Дмитрий on 09.03.2022.
//

import Foundation
import Combine
import SwiftUI

class ProfileViewModel: ObservableObject {
    
    let action: PassthroughSubject<Action, Never> = .init()
    
    @Published var productViewModel: ProfileCardViewComponent.ViewModel
    @Published var buttonsViewModel: ProfileButtonsSectionView.ViewModel
    @Published var detailAccountViewModel: DetailAccountViewComponent.ViewModel?
    @Published var historyViewModel: HistoryViewComponent.ViewModel?
    @Published var alert: Alert.ViewModel?
    @Published var detailOperation: OperationDetailViewModel?
    
    lazy var dismissAction: () -> Void = {[weak self] in
        self?.action.send(ProductProfileViewModelAction.Dismiss())
    }
    
    private let model: Model
    private var bindings = Set<AnyCancellable>()
    
    internal init(productViewModel: ProfileCardViewComponent.ViewModel, model: Model) {
        
        self.model = model
        self.productViewModel = productViewModel
        
        self.detailAccountViewModel = nil
        
        self.buttonsViewModel = .init(kind: productViewModel.product.productType)
        self.historyViewModel = .init(model, productId: productViewModel.product.productId, productType: productViewModel.product.productType)
        
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
