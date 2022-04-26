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
    
    lazy var customNameAction: () -> Void = {[weak self] in
        self?.action.send(ProductProfileViewModelAction.CustomName())
    }
    
    private let model: Model
    private var bindings = Set<AnyCancellable>()
    
    internal init(productViewModel: ProfileCardViewComponent.ViewModel, model: Model) {
        
        self.model = model
        self.productViewModel = productViewModel
        
        self.detailAccountViewModel = nil
        
        self.buttonsViewModel = .init(kind: productViewModel.product.productType)
        self.historyViewModel = .init(model, productId: productViewModel.product.productId, productType: productViewModel.product.productType)
        
        if productViewModel.product.productType == .loan {
            
            self.historyViewModel = nil
            if let product =  model.products.value[productViewModel.product.productType]?.filter({$0.id == productViewModel.product.productId}).first as? ProductCardData, let loanBase = product.loanBaseParam {
                self.detailAccountViewModel = .init(with: loanBase, status: .active, isCredit: false, productName: nil, longInt: nil)
            } else {
                
                self.detailAccountViewModel = nil
            }
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
                case _ as ProductProfileViewModelAction.CustomName:
                    break
                case _ as ProductProfileViewModelAction.DetailOperation:
                    break
                default:
                    break
                }
            }.store(in: &bindings)
        
        buttonsViewModel.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                switch action {
                default:
                    break
                }
            }.store(in: &bindings)
    }
    
    func detailHistory() -> OperationDetailViewModel {
        OperationDetailViewModel(with: .init(mcc: 1, accountId: 2, accountNumber: "", amount: 2, cardTranNumber: "", city: "", comment: "", country: "", currencyCodeNumeric: 2, date: Date(), deviceCode: "", documentAmount: 2, documentId: 2, fastPayment: .init(documentComment: "", foreignBankBIC: "", foreignBankID: "", foreignBankName: "", foreignName: "", foreignPhoneNumber: "", opkcid: ""), groupName: "", isCancellation: true, md5hash: "", merchantName: "", merchantNameRus: "", opCode: 2, operationId: "", operationType: .credit, paymentDetailType: .c2b, svgImage: .init(description: ""), terminalCode: "", tranDate: Date(), type: .inside), currency: "", product: (model.products.value[.card]?.first(where: {$0.id == 1})!)!)!
    }
}

enum ProductProfileViewModelAction {
    
    struct CustomName: Action {}
    
    struct ActivateCard {
        
        let productId: Int
    }
    struct DetailOperation {
    }
    
    struct Dismiss: Action {}
}
