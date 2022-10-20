//
//  PaymentsCardViewComponent+Legacy.swift
//  ForaBank
//
//  Created by Max Gribov on 16.03.2022.
//

import Foundation
import SwiftUI

extension PaymentsProductView.ViewModel {
    
    convenience init(parameterProduct: Payments.ParameterProduct, model: Model) {
        
        self.init(title: "",
                  cardIcon: Self.cardIconPlaceholder,
                  paymentSystemIcon: nil,
                  name: "",
                  amount: "",
                  captionItems: [],
                  state: .normal,
                  model: model,
                  parameterProduct: parameterProduct)
        
        if let value = parameterProduct.parameter.value,
           let productId = Int(value),
           let product = model.product(productId: productId)  {
            
                update(with: product)
            
        } else {
            
            if let firstProduct = model.allProducts.first {
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
                case _ as PaymentsProductView.ViewModelAction.ToggleSelector:
                    
                    withAnimation {
                        
                        switch state {
                        case .normal:
                            
                            let productObjects = model.allProducts
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
                    
                    guard let productObject = model.product(productId: payload.productId)
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
