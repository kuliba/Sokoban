//
//  PaymentsMeToMeViewModel.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 26.09.2022.
//

import SwiftUI
import Combine

// MARK: - ViewModel

class PaymentsMeToMeViewModel: ObservableObject {
    
    private let model: Model
    let swapViewModel: ProductsSwapView.ViewModel
    let paymentsAmount: PaymentsAmountView.ViewModel
        
    let title: String
    let closeAction: () -> Void
    
    init(_ model: Model, swapViewModel: ProductsSwapView.ViewModel, paymentsAmount: PaymentsAmountView.ViewModel, title: String = "Между своими", closeAction: @escaping () -> Void) {
        
        self.model = model
        self.swapViewModel = swapViewModel
        self.paymentsAmount = paymentsAmount
        self.title = title
        self.closeAction = closeAction
    }
    
    convenience init(_ model: Model, type: Mode, closeAction: @escaping () -> Void) {
        
        switch type {
        case let .general(productData):
            
            let swapViewModel = Self.makeSwap(model, productData: productData)
            let amountViewModel = Self.makeAmount()
            
            self.init(model, swapViewModel: swapViewModel, paymentsAmount: amountViewModel, closeAction: closeAction)
        }
    }
}

// MARK: - Mode

extension PaymentsMeToMeViewModel {
    
    enum Mode {
        
        case general(ProductData)
    }
}

// MARK: - Make

extension PaymentsMeToMeViewModel {
    
    static func makeSwap(_ model: Model, productData: ProductData) -> ProductsSwapView.ViewModel {
        
        let contextFrom: ProductSelectorView.ViewModel.Context = .init(title: "Откуда", direction: .from)
        let contextTo: ProductSelectorView.ViewModel.Context = .init(title: "Куда", direction: .to)
        
        let from: ProductSelectorView.ViewModel = .init(model, productData: productData, productsList: .init(model: model, context: contextFrom), context: contextFrom)
        let to: ProductSelectorView.ViewModel = .init(model, context: contextTo)
        
        return .init(model: model, items: [from, to])
    }
}

// MARK: - Methods

extension PaymentsMeToMeViewModel {
    
    static func makeAmount() -> PaymentsAmountView.ViewModel {

        .init(title: "Сумма перевода",
              amount: 0,
              transferButton: .active(title: "Перевести") {},
              info: .button(title: "Без комиссии", icon: .ic16Info, action: {}))
    }
}
