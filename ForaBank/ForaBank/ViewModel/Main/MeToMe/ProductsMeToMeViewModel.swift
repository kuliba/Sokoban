//
//  ProductsMeToMeViewModel.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 26.09.2022.
//

import Combine

// MARK: - ViewModel

/*
 struct MeToMeViewModel {
     
     let type: Kind
     let closeAction: () -> Void
  
     init(type: Kind = .general, closeAction: @escaping () -> Void) {
         
         self.type = type
         self.closeAction = closeAction
     }
     
     enum Kind {
         case general
         case template(PaymentTemplateData)
         case refill(ProductData)
         case transferDepositRemains(ProductData, Double)
         case transferDepositInterest(ProductData, Double)
         case closeAccount(ProductData, Double)
     }
 }
 */

class ProductsMeToMeViewModel: ObservableObject {
    
    private let model: Model
    let swapViewModel: ProductsSwapView.ViewModel
    let paymentsAmount: PaymentsAmountView.ViewModel
    
    let type: Kind
    let closeAction: () -> Void
    
    let title = "Между своими"
    
    init(model: Model, swapViewModel: ProductsSwapView.ViewModel, paymentsAmount: PaymentsAmountView.ViewModel, type: Kind = .general, closeAction: @escaping () -> Void) {
        
        self.model = model
        self.swapViewModel = swapViewModel
        self.paymentsAmount = paymentsAmount
        self.type = type
        self.closeAction = closeAction
    }
    
    convenience init(model: Model, type: Kind = .general, closeAction: @escaping () -> Void) {
        
        Self.makeKind(type)
        
        self.init(model: model, items: [], amount: 0)
    }
    
    convenience init(model: Model, items: [ProductSelectorView.ViewModel], amount: Double) {
        
        let swapViewModel = Self.makeSwap(model, items: items)
        let paymentsAmount = Self.makePaymentsAmount(model, amount: amount)
        
        self.init(model: model, swapViewModel: swapViewModel, paymentsAmount: paymentsAmount, closeAction: {})
    }
}

extension ProductsMeToMeViewModel {
    
    enum Kind {
        
        case general
        case template(PaymentTemplateData)
        case refill(ProductData)
        case transferDepositRemains(ProductData, Double)
        case transferDepositInterest(ProductData, Double)
        case closeAccount(ProductData, Double)
    }
}

extension ProductsMeToMeViewModel {
    
    static func makeKind(_ type: Kind) {
        
        switch type {
        case .general:
            break
        case .template(_):
            break
        case .refill(_):
            break
        case .transferDepositRemains(_, _):
            break
        case .transferDepositInterest(_, _):
            break
        case .closeAccount(_, _):
            break
        }
    }
    
    static func makeSwap(_ model: Model, items: [ProductSelectorView.ViewModel]) -> ProductsSwapView.ViewModel {
        
        let swapViewModel: ProductsSwapView.ViewModel = .init(model: model, items: items)
        return swapViewModel
    }
    
    static func makeSelector(_ model: Model, productData: ProductData, context: ProductSelectorView.ViewModel.Context) -> ProductSelectorView.ViewModel {
        
        let productViewModel = ProductSelectorView.ViewModel.makeProduct(model, productData: productData)
        
        return .init(model: model,
                     productViewModel: productViewModel,
                     context: context)
    }
    
    static func makePaymentsAmount(_ model: Model, amount: Double) -> PaymentsAmountView.ViewModel {
        
        .init(title: "Сумма перевода",
              amount: amount,
              transferButton: .active(title: "Перевести") {})
    }
}
