//
//  PaymentsCardViewComponent+Legacy.swift
//  ForaBank
//
//  Created by Max Gribov on 16.03.2022.
//

import Foundation
import SwiftUI
import RealmSwift

extension PaymentsCardView.ViewModel {
    
    convenience init(parameterCard: Payments.ParameterCard) {
        
        self.init(title: "", cardIcon: Self.cardIconPlaceholder, paymentSystemIcon: nil, name: "", amount: "", captionItems: [], state: .normal, model: .emptyMock, parameterCard: parameterCard)
        
        if let realm = try? Realm(),
           let product = productObject(products: realm.objects(UserAllCardsModel.self), value: parameterCard.parameter.value) {
            
            update(with: product)
        }
        
        bindLegacy()
    }
    
    func bindLegacy() {
        
        action
            .receive(on: DispatchQueue.main)
            .sink {[unowned self] action in
                
                switch action {
                case _ as PaymentsCardView.ViewModelAction.ToggleSelector:
                    
                    withAnimation {
                        
                        switch state {
                        case .normal:
                            
                            guard let realm = try? Realm() else { return }
                            
                            let productObjects: [UserAllCardsModel] = realm.objects(UserAllCardsModel.self).map{ $0 }
                            guard productObjects.isEmpty == false else {
                                return
                            }
                            
                            let selectorViewModel = PaymentsProductSelectorView.ViewModel(data: productObjects)
                            state = .expanded(selectorViewModel)
                            bindLegacy(selector: selectorViewModel)
                            
                        case .expanded:
                            state = .normal
                        }
                    }

                default:
                    break
                }
                
            }.store(in: &bindings)
    }
    
    func bindLegacy(selector: PaymentsProductSelectorView.ViewModel) {

        selectorBinding = selector.action
            .receive(on: DispatchQueue.main)
            .sink {[unowned self] action in
                
                switch action {
                case let payload as PaymentsProductSelectorView.ViewModelAction.SelectedProduct:
                    
                    guard let realm = try? Realm(), let productObject = realm.objects(UserAllCardsModel.self).first(where: { $0.id == payload.productId })  else { return }
                    
                    update(with: productObject)
                    withAnimation {
                        state = .normal
                    }
  
                default:
                    break
                }
            }
    }
    
    func update(with productObject: UserAllCardsModel) {
        
        guard let cardIconImage = productObject.smallDesign?.convertSVGStringToImage(),
        let name = productObject.customName ?? productObject.mainField,
        let currency = productObject.currency,
        let cardNumber = productObject.accountNumber?.suffix(4) else {
            return
        }
        
        self.cardIcon = Image(uiImage: cardIconImage)

        if let paymentSystemImage = productObject.paymentSystemImage?.convertSVGStringToImage() {
            
            self.paymentSystemIcon = Image(uiImage: paymentSystemImage)
            
        } else {
            
            self.paymentSystemIcon = nil
        }
        
        self.name = name
        self.amount = productObject.balance.currencyFormatter(symbol: currency)
        self.captionItems = [.init(title: String(cardNumber))]
        
        update(value: "\(productObject.id)")
    }
    
    func productObject(products: Results<UserAllCardsModel>, value: String?) -> UserAllCardsModel? {
        
        if let value = value, let productId = Int(value) {
            
            return products.first(where: { $0.id == productId })
            
        } else {
            
            return products.first
        }
    }
}
