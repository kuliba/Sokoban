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
    
    let action: PassthroughSubject<Action, Never> = .init()
    @Published var isShowSpinner: Bool
    
    private let model: Model
    
    let swapViewModel: ProductsSwapView.ViewModel
    let paymentsAmount: PaymentsAmountView.ViewModel
        
    let title: String
    let closeAction: () -> Void
    
    private var bindings = Set<AnyCancellable>()
    private var bindingsFrom = Set<AnyCancellable>()

    init(_ model: Model, swapViewModel: ProductsSwapView.ViewModel, paymentsAmount: PaymentsAmountView.ViewModel, title: String = "Между своими", isShowSpinner: Bool = false, closeAction: @escaping () -> Void) {
        
        self.model = model
        self.swapViewModel = swapViewModel
        self.paymentsAmount = paymentsAmount
        self.title = title
        self.isShowSpinner = isShowSpinner
        self.closeAction = closeAction
    }
    
    convenience init?(_ model: Model, mode: Mode, closeAction: @escaping () -> Void) {

        guard let productData = model.product() else {
            return nil
        }
        
        let swapViewModel: ProductsSwapView.ViewModel = .init(model, productData: productData, mode: mode)
        let amountViewModel: PaymentsAmountView.ViewModel = .init(productData: productData)
        
        self.init(model, swapViewModel: swapViewModel, paymentsAmount: amountViewModel, closeAction: closeAction)
        
        bind()
        updateAmount()
    }
    
    private func bind() {
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [weak self] action in
                
                guard let self = self else {
                    return
                }
                
                switch action {
                case let payload as ModelAction.CurrencyWallet.ExchangeOperations.Start.Response:
                    
                    switch payload.result {
                        
                    case let .success(response):
                        
                        if response.needMake == true {
                            
                            self.model.action
                                .receive(on: DispatchQueue.main)
                                .sink { action in
                                    
                                    switch action {
                                    case let payload as ModelAction.CurrencyWallet.ExchangeOperations.Approve.Response:
                                        
                                        switch payload {
                                            
                                        case let .successed(success):
                                            
                                            if let documentStatus = success.documentStatus {
                                                
                                                let successMeToMe: PaymentsSuccessMeToMeViewModel = .init(self.model, state: .success(documentStatus, success.paymentOperationDetailId), confirmationData: response)
                                                
                                                self.action.send(PaymentsMeToMeAction.Response.Success(viewModel: successMeToMe))
                                            }
                                            
                                        case let .failed(error):
                                            
                                            let successMeToMe: PaymentsSuccessMeToMeViewModel = .init(self.model, state: .failed(error), confirmationData: response)
                                            
                                            self.action.send(PaymentsMeToMeAction.Response.Success(viewModel: successMeToMe))
                                        }
                                        
                                        self.close()
                                        
                                    default:
                                        break
                                    }
                                    
                                }.store(in: &self.bindings)
                            
                            self.model.action.send(ModelAction.CurrencyWallet.ExchangeOperations.Approve.Request())
                            
                        } else {
                            self.close()
                        }
                        
                    case .failure:
                        self.close()
                    }
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case _ as PaymentsMeToMeAction.Button.Transfer.Tap:
                    
                    let productsId = Self.productsId(model, swapViewModel: swapViewModel)
                    let value = paymentsAmount.textField.value
                    
                    if let productsId = productsId, let product = model.product(productId: productsId.from) {
                        
                        isShowSpinner = true
                        
                        model.action.send(ModelAction.CurrencyWallet.ExchangeOperations.Start.Request(
                            amount: value,
                            currency: product.currency,
                            productFrom: productsId.from,
                            productTo: productsId.to))
                    }

                case _ as PaymentsMeToMeAction.Button.Info.Tap:
                    break
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
        
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
    
    private func updateAmount() {
        
        paymentsAmount.transferButton = .active(title: "Перевести") {
            self.action.send(PaymentsMeToMeAction.Button.Transfer.Tap())
        }
        
        paymentsAmount.info = .button(title: "Без комиссии", icon: .ic16Info, action: {
            self.action.send(PaymentsMeToMeAction.Button.Info.Tap())
        })
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
    
    private func close() {
        
        isShowSpinner = false
        closeAction()
    }
}

extension PaymentsMeToMeViewModel {
    
    static private func productsId(_ model: Model, swapViewModel: ProductsSwapView.ViewModel) -> (from: ProductData.ID, to: ProductData.ID)? {
        
        var productsId: (from: ProductData.ID, to: ProductData.ID) = (0, 0)
        
        if let from = swapViewModel.from, let to = swapViewModel.to {
            
            switch from.content {
            case let .product(productViewModel):
                
                productsId.from = productViewModel.id
                
            case .placeholder:
                return nil
            }
            
            switch to.content {
            case let .product(productViewModel):
                
                productsId.to = productViewModel.id
                
            case .placeholder:
                return nil
            }
        }
        
        return productsId
    }
}

// MARK: - Action

enum PaymentsMeToMeAction {
    
    enum Button {
        
        enum Transfer {
            
            struct Tap: Action {}
        }
        
        enum Info {
            
            struct Tap: Action {}
        }
    }
    
    enum Response {
    
        struct Success: Action {
            
            let viewModel: PaymentsSuccessMeToMeViewModel
        }
    }
}

// MARK: - Mode

extension PaymentsMeToMeViewModel {
    
    enum Mode {
        
        case general
    }
}
