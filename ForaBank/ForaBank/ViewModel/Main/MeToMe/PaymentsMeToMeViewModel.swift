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
    @Published var state: State
    
    private let model: Model
    
    let swapViewModel: ProductsSwapView.ViewModel
    let paymentsAmount: PaymentsAmountView.ViewModel
        
    let title: String
    let closeAction: () -> Void
    
    private var bindings = Set<AnyCancellable>()
    private var bindingsSwap = Set<AnyCancellable>()
    
    enum State {
        
        case normal
        case loading
    }

    init(_ model: Model, swapViewModel: ProductsSwapView.ViewModel, paymentsAmount: PaymentsAmountView.ViewModel, title: String = "Между своими", state: State = .normal, closeAction: @escaping () -> Void) {
        
        self.model = model
        self.swapViewModel = swapViewModel
        self.paymentsAmount = paymentsAmount
        self.title = title
        self.state = state
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
    }
    
    private func bind() {
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in

                switch action {
                case let payload as ModelAction.CurrencyWallet.ExchangeOperations.Start.Response:
                    
                    switch payload.result {
                    case let .success(response):

                        // For currency transfers
                        if response.needMake == true {

                            bind(response)
                            model.action.send(ModelAction.CurrencyWallet.ExchangeOperations.Approve.Request())
                            
                        } else {
                            
                            // For ruble transfers
                            if response.needOTP == false, let documentStatus = response.documentStatus {
                                
                                let successMeToMe: PaymentsSuccessMeToMeViewModel = .init(model, state: .success(documentStatus, response.paymentOperationDetailId), responseData: response)
                                
                                self.action.send(PaymentsMeToMeAction.Response.Success(viewModel: successMeToMe))
                            }
                            
                            close()
                        }
                        
                    case .failure:
                        close()
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
                        
                        state = .loading
                        
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
                
                if let from = items.first, let to = items.last {
                    
                    switch from.content {
                    case let .product(viewModel):
                        
                        updateAmountSwitch(from: viewModel.id)
                        updateTextField(viewModel.id, textField: paymentsAmount.textField)
                        
                    case .placeholder:
                        break
                    }
                    
                    // After swap elements in items
                    bindingsSwap = Set<AnyCancellable>()
                    
                    from.action
                        .receive(on: DispatchQueue.main)
                        .sink { [unowned self] action in
                            
                            switch action {
                            case let payload as ProductSelectorAction.Selected:
                                
                                updateAmountSwitch(from: payload.id)
                                updateTextField(payload.id, textField: paymentsAmount.textField)
                                
                            default:
                                break
                            }
                            
                        }.store(in: &bindingsSwap)
                    
                    to.action
                        .receive(on: DispatchQueue.main)
                        .sink { [unowned self] action in
                            
                            switch action {
                            case let payload as ProductSelectorAction.Selected:
                                updateAmountSwitch(to: payload.id)
                                
                            default:
                                break
                            }
                            
                        }.store(in: &bindingsSwap)
                }
                
            }.store(in: &bindings)
        
        $state
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] state in
                
                switch state {
                case .normal:
                    
                    paymentsAmount.transferButton = .active(title: "Перевести") {
                        self.action.send(PaymentsMeToMeAction.Button.Transfer.Tap())
                    }
                    
                    paymentsAmount.info = .button(title: "Без комиссии", icon: .ic16Info, action: {
                        self.action.send(PaymentsMeToMeAction.Button.Info.Tap())
                    })
                    
                case .loading:
                    paymentsAmount.transferButton = .loading(icon: .init("Logo Fora Bank"), iconSize: .init(width: 40, height: 40))
                }

            }.store(in: &bindings)
    }
    
    private func bind(_ response: TransferResponseData) {
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as ModelAction.CurrencyWallet.ExchangeOperations.Approve.Response:
                    
                    switch payload {
                    case let .successed(success):
                        
                        if let documentStatus = success.documentStatus {
                            
                            let successMeToMe: PaymentsSuccessMeToMeViewModel = .init(model, state: .success(documentStatus, success.paymentOperationDetailId), responseData: response)
                            
                            self.action.send(PaymentsMeToMeAction.Response.Success(viewModel: successMeToMe))
                        }
                        
                    case let .failed(error):
                        
                        let successMeToMe: PaymentsSuccessMeToMeViewModel = .init(model, state: .failed(error), responseData: response)
                        
                        self.action.send(PaymentsMeToMeAction.Response.Success(viewModel: successMeToMe))
                    }
                    
                    self.close()
                    
                default:
                    break
                }
                
            }.store(in: &self.bindings)
    }
    
    private func updateAmountSwitch(from id: ProductData.ID) {
        
        if let to = swapViewModel.to {
            
            switch to.content {
            case let .product(viewModel):
                updateAmountSwitch(from: id, to: viewModel.id)
                
            case .placeholder:
                break
            }
        }
    }
    
    private func updateAmountSwitch(to id: ProductData.ID) {
        
        if let from = swapViewModel.from {
            
            switch from.content {
            case let .product(viewModel):
                updateAmountSwitch(from: viewModel.id, to: id)
                
            case .placeholder:
                break
            }
        }
    }
    
    private func updateAmountSwitch(from: ProductData.ID, to: ProductData.ID) {
        
        let from = model.product(productId: from)
        let to = model.product(productId: to)
        
        guard let from = from, let to = to else {
            return
        }
        
        let currencyData = model.currencyList.value
        
        let fromItem = currencyData.first(where: { $0.code == from.currency.description })
        let toItem = currencyData.first(where: { $0.code == to.currency.description })
        
        guard let fromItem = fromItem,
              let toItem = toItem,
              let fromCurrencySymbol = fromItem.currencySymbol,
              let toCurrencySymbol = toItem.currencySymbol else {
            return
        }
        
        paymentsAmount.currencySwitch = .init(
            from: fromCurrencySymbol,
            to: toCurrencySymbol,
            icon: .init("Payments Refresh CW")) {
                self.swapViewModel.action.send(ProductsSwapAction.Button.Tap())
            }
    }
    
    private func updateTransferButton() {
        
        let value = paymentsAmount.textField.value
        
        let transferButton = PaymentsAmountView.ViewModel.makeTransferButton(value) {
            self.action.send(PaymentsMeToMeAction.Button.Transfer.Tap())
        }
        
        paymentsAmount.transferButton = transferButton
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
        
        state = .normal
        closeAction()
        
        bindings.removeAll()
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
