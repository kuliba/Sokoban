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
    @Published var selector: ProductProfileButtonsSectionView.ViewModel
    @Published var product: ProductProfileCardView.ViewModel
    @Published var detail: ProductProfileAccountDetailView.ViewModel?
    @Published var history: ProductProfileHistoryView.ViewModel?
    @Published var alert: Alert.ViewModel?
    @Published var operationDetail: OperationDetailViewModel?

    private let model: Model
    private var bindings = Set<AnyCancellable>()
    
    
    init(productViewModel: ProductProfileCardView.ViewModel, model: Model, dismissAction: @escaping () -> Void) {
        
        self.statusBar = ProductProfileViewModel.StatusBarViewModel(backButton: .init(icon: .ic24ChevronLeft, action: dismissAction), title: "Platinum", subtitle: "· 4329", actionButton: .init(icon: .ic24Edit2, action: {}), color: .iconBlack)
        self.model = model
        self.product = productViewModel

        self.detail = nil
        
        self.selector = .init(kind: productViewModel.product.productType)
        self.history = .init(model, productId: productViewModel.product.id, productType: productViewModel.product.productType)
        
        switch productViewModel.product.productType {
        case .card:
            break
        case .account:
            break
        case .deposit:
            break
        case .loan:
            self.history = nil
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
        
        history?.action
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
}
