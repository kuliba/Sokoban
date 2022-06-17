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

    private var historyPool = [ProductData.ID : ProductProfileHistoryView.ViewModel]()
    private let model: Model
    private var bindings = Set<AnyCancellable>()
    
    init(statusBar: StatusBarViewModel, product: ProductProfileCardView.ViewModel, buttons: ProductProfileButtonsView.ViewModel, detail: ProductProfileDetailView.ViewModel?, history: ProductProfileHistoryView.ViewModel?, alert: Alert.ViewModel? = nil, operationDetail: OperationDetailViewModel? = nil, accentColor: Color = .purple, model: Model = .emptyMock) {
        
        self.statusBar = statusBar
        self.product = product
        self.buttons = buttons
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
        self.buttons = .init(with: productData)
        let historyViewModel = ProductProfileHistoryView.ViewModel(model, productId: productData.id)
        self.history = historyViewModel
        self.accentColor = .clear
        self.model = model
        
        self.historyPool[productData.id] = historyViewModel

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
                
                withAnimation {
                    
                    statusBar.title = productViewModel.name
                    statusBar.subtitle = productViewModel.header.number ?? ""
                    statusBar.color = productViewModel.appearance.textColor
                    accentColor = productViewModel.appearance.background.color
                }
                
                if let historyViewModel = historyPool[productViewModel.id] {
                    
                    withAnimation {
                        history = historyViewModel
                    }
                    
                } else {
                    
                    let historyViewModel = ProductProfileHistoryView.ViewModel(model, productId: productViewModel.id)
                   
                    withAnimation {
                        history = historyViewModel
                    }
                    
                    historyPool[productViewModel.id] = historyViewModel
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
    
    struct ProductDetail: Action {
        
        let productId: Int
    }
}
