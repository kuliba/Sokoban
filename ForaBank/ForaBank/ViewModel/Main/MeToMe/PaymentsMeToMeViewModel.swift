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
    
    private var bindings = Set<AnyCancellable>()
    private var bindingsFrom = Set<AnyCancellable>()
    
    init(_ model: Model, swapViewModel: ProductsSwapView.ViewModel, paymentsAmount: PaymentsAmountView.ViewModel, title: String = "Между своими", closeAction: @escaping () -> Void) {
        
        self.model = model
        self.swapViewModel = swapViewModel
        self.paymentsAmount = paymentsAmount
        self.title = title
        self.closeAction = closeAction
    }
    
    convenience init?(_ model: Model, mode: Mode, closeAction: @escaping () -> Void) {

        guard let productData = model.product() else {
            return nil
        }
        
        let swapViewModel: ProductsSwapView.ViewModel = .init(model, productData: productData, mode: mode)
        let amountViewModel: PaymentsAmountView.ViewModel = .init(productData: productData) {} infoAction: {}
        
        self.init(model, swapViewModel: swapViewModel, paymentsAmount: amountViewModel, closeAction: closeAction)
        
        bind()
    }
    
    private func bind() {
        
        swapViewModel.$items
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] items in
                
                if let from = items.first {
                    
                    switch from.content {
                    case let .product(viewModel):
                        
                        updateTextField(viewModel.id, textField: paymentsAmount.textField)
                        
                    case .placeholder:
                        break
                    }
                    
                    bindingsFrom = Set<AnyCancellable>()
                    
                    from.action
                        .receive(on: DispatchQueue.main)
                        .sink { [unowned self] action in
                            
                            switch action {
                            case let payload as ProductSelectorAction.Selected:
                                
                                updateTextField(payload.id, textField: paymentsAmount.textField)
                                
                            default:
                                break
                            }
                            
                        }.store(in: &bindingsFrom)
                }
                
            }.store(in: &bindings)
    }
    
    private func updateTextField(_ id: ProductData.ID, textField: TextFieldFormatableView.ViewModel) {
        
        if let product = model.product(productId: id) {

            let currency = Currency(description: product.currency)
            let formatter: NumberFormatter = .currency(with: currency.currencySymbol)

            guard let stringValue = formatter.string(from: .init(value: textField.value)) else {
                return
            }
            
            textField.formatter.currencySymbol = currency.currencySymbol
            textField.text = stringValue
        }
    }
}

// MARK: - Mode

extension PaymentsMeToMeViewModel {
    
    enum Mode {
        
        case general
    }
}
