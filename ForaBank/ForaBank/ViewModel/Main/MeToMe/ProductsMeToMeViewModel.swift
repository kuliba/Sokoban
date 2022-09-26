//
//  ProductsMeToMeViewModel.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 26.09.2022.
//

import Combine

// MARK: - ViewModel

class ProductsMeToMeViewModel: ObservableObject {
    
    private let model: Model
    let swapViewModel: ProductsSwapView.ViewModel
    let paymentsAmount: PaymentsAmountView.ViewModel
    
    let title = "Между своими"
    
    init(model: Model, swapViewModel: ProductsSwapView.ViewModel, paymentsAmount: PaymentsAmountView.ViewModel) {
        
        self.model = model
        self.swapViewModel = swapViewModel
        self.paymentsAmount = paymentsAmount
    }
    
    convenience init(model: Model, items: [ProductSelectorView.ViewModel], amount: Double) {
        
        let swapViewModel = Self.makeSwap(model, items: items)
        let paymentsAmount = Self.makePaymentsAmount(model, amount: amount)
        
        self.init(model: model, swapViewModel: swapViewModel, paymentsAmount: paymentsAmount)
    }
}

extension ProductsMeToMeViewModel {
    
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
