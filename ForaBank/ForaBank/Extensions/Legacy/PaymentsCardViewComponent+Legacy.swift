//
//  PaymentsCardViewComponent+Legacy.swift
//  ForaBank
//
//  Created by Max Gribov on 16.03.2022.
//

import Foundation
import SwiftUI

extension PaymentsCardView.ViewModel {
    
    convenience init(parameterCard: Payments.ParameterCard) {
        
        self.init(title: "",
                  cardIcon: Self.cardIconPlaceholder,
                  paymentSystemIcon: nil,
                  name: "",
                  amount: "",
                  captionItems: [],
                  state: .normal,
                  model: .emptyMock,
                  parameterCard: parameterCard)
        
        if let value = parameterCard.parameter.value,
           let productId = Int(value),
           let product = model.paymentsProduct(with: productId)  {
            
                update(with: product)
            
        } else {
            
            if let firstProduct = model.productsData.first {
                update(with: firstProduct)
            }
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
                            
                            let productObjects = model.productsData
                            guard productObjects.isEmpty == false else {
                                return
                            }
                            
                            let selectorViewModel = PaymentsProductSelectorView.ViewModel.init(productsData: productObjects, model: model)
                            
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
                    
                    guard let productObject = model.paymentsProduct(with: payload.productId)
                    else { return }
                    
                    update(with: productObject)
                    withAnimation {
                        state = .normal
                    }
  
                default:
                    break
                }
            }
    }
    
    func update(with productObject: ProductData) {
        
        guard let cardIconImage = productObject.smallDesign.uiImage,
              let cardNumber = productObject.accountNumber?.suffix(4)
        else { return }
        
        let name = productObject.customName ?? productObject.mainField
        let balance = productObject.balance ?? 0
        
        self.cardIcon = Image(uiImage: cardIconImage)

        if let productCardData = productObject as? ProductCardData,
           let paymentSystemImage = productCardData.paymentSystemImage?.uiImage {
            
            self.paymentSystemIcon = Image(uiImage: paymentSystemImage)
            
        } else {
            
            self.paymentSystemIcon = nil
        }
        
        self.name = name
        self.amount = balance.currencyFormatter(symbol: productObject.currency)
        self.captionItems = [.init(title: String(cardNumber))]
        
        update(value: "\(productObject.id)")
    }
    
}
