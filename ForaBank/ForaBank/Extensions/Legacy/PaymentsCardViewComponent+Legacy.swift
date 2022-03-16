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
    
    convenience init?(parameterCard: Payments.ParameterCard) {
        
        guard let realm = try? Realm(),
        let productObject = realm.objects(UserAllCardsModel.self).first,
        let cardIconImage = productObject.smallDesign?.convertSVGStringToImage(),
        let name = productObject.customName ?? productObject.mainField,
        let currency = productObject.currency,
        let cardNumber = productObject.accountNumber?.suffix(4) else {
            return nil
        }
        
        let title = "Счет списания"
        let cardIcon = Image(uiImage: cardIconImage)
        var paymentSystemIcon: Image? = nil
        if let paymentSystemImage = productObject.paymentSystemImage?.convertSVGStringToImage() {
            paymentSystemIcon = Image(uiImage: paymentSystemImage)
        }
        let amount = productObject.balance.currencyFormatter(symbol: currency)
 
        self.init(title: title, cardIcon: cardIcon, paymentSystemIcon: paymentSystemIcon, name: name, amount: amount, captionItems: [.init(title: String(cardNumber))], state: .normal, model: .emptyMock, parameterCard: parameterCard)
        
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
                    
                    if update(with: productObject) == true {
                        
                        withAnimation {
                            
                            state = .normal
                        }
                    }
  
                default:
                    break
                }
            }
    }
    
    func update(with productObject: UserAllCardsModel) -> Bool {
        
        guard let cardIconImage = productObject.smallDesign?.convertSVGStringToImage(),
        let name = productObject.customName ?? productObject.mainField,
        let currency = productObject.currency,
        let cardNumber = productObject.accountNumber?.suffix(4) else {
            return false
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
        
        return true
    }
    
}
