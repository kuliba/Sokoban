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
    @Published var alert: Alert.ViewModel?
    
    let swapViewModel: ProductsSwapView.ViewModel
    let paymentsAmount: PaymentsAmountView.ViewModel
        
    let title: String
    let closeAction: () -> Void
    
    private let model: Model
    private var bindings = Set<AnyCancellable>()
    
    enum State {
        
        case normal
        case loading
    }

    init(_ model: Model, swapViewModel: ProductsSwapView.ViewModel, paymentsAmount: PaymentsAmountView.ViewModel, title: String, state: State = .normal, closeAction: @escaping () -> Void) {
        
        self.model = model
        self.swapViewModel = swapViewModel
        self.paymentsAmount = paymentsAmount
        self.title = title
        self.state = state
        self.closeAction = closeAction
    }
    
    convenience init?(_ model: Model, mode: Mode, closeAction: @escaping () -> Void) {

        guard let products = model.allProducts(),
              let productData = Self.reduce(products: products) else {
            return nil
        }
        
        let swapViewModel: ProductsSwapView.ViewModel = .init(model, productData: productData, mode: mode)
        let amountViewModel: PaymentsAmountView.ViewModel = .init(productData: productData)
        
        self.init(model, swapViewModel: swapViewModel, paymentsAmount: amountViewModel, title: "Между своими", state: .normal, closeAction: closeAction)
        
        bind()
    }
    
    private func bind() {
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in

                switch action {
                case let payload as ModelAction.Payment.MeToMe.CreateTransfer.Response:
                    
                    switch payload.result {
                    case let .success(response):

                        // For currency transfers
                        if response.needMake == true {

                            model.action.send(ModelAction.Payment.MeToMe.MakeTransfer.Request(transferResponse: response))

                        } else {
                            
                            // For ruble transfers
                            if response.needOTP == false, let documentStatus = response.documentStatus {
                                
                                let successMeToMe: PaymentsSuccessMeToMeViewModel = .init(model, state: .success(documentStatus, response.paymentOperationDetailId), responseData: response)
                                
                                self.action.send(PaymentsMeToMeAction.Response.Success(viewModel: successMeToMe))
                                
                            } else {
                                
                                self.action.send(PaymentsMeToMeAction.Response.Failed())
                            }
                        }
                        
                    case let .failure(error):
                        makeAlert(error)
                    }
                    
                case let payload as ModelAction.Payment.MeToMe.MakeTransfer.Response:
                    
                    switch payload.result {
                    case let .success(success):
                        
                        if let documentStatus = success.documentStatus {
                            
                            let successMeToMe: PaymentsSuccessMeToMeViewModel = .init(model, state: .success(documentStatus, success.paymentOperationDetailId), responseData: payload.transferResponse)
                            
                            self.action.send(PaymentsMeToMeAction.Response.Success(viewModel: successMeToMe))
                        }
                        
                    case let .failure(error):
                        
                        let successMeToMe: PaymentsSuccessMeToMeViewModel = .init(model, state: .failed(error), responseData: payload.transferResponse)
                        
                        self.action.send(PaymentsMeToMeAction.Response.Success(viewModel: successMeToMe))
                    }
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
        
        model.rates
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] rates in
                
                updateInfoButton(rates)
                
            }.store(in: &bindings)
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case _ as PaymentsMeToMeAction.Button.Transfer.Tap:
                    
                    let productsId = Self.productsId(model, swapViewModel: swapViewModel)
                    
                    if let productsId = productsId, let product = model.product(productId: productsId.from) {
                        
                        if productsId.from == productsId.to {
                            
                            makeAlert(.emptyData(message: "Счет списания совпадает со счетом зачисления. Выберите другой продукт"))

                        } else {
                            
                            state = .loading
                            
                            model.action.send(ModelAction.Payment.MeToMe.CreateTransfer.Request(
                                amount: paymentsAmount.textField.value,
                                currency: product.currency,
                                productFrom: productsId.from,
                                productTo: productsId.to))
                        }
                    }

                case _ as PaymentsMeToMeAction.Button.Info.Tap:
                    break
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
        
        swapViewModel.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case _ as ProductsSwapAction.Swapped:
                    
                    guard let productIdFrom = swapViewModel.productIdFrom else {
                        return
                    }
                    
                    updateAmountSwitch(from: productIdFrom)
                    updateTextField(productIdFrom, textField: paymentsAmount.textField)
                    updateInfoButton(model.rates.value)
                    sendUpdateRates()
                    
                case let payload as ProductsSwapAction.Selected.From:
                    
                    updateAmountSwitch(from: payload.productId)
                    updateTextField(payload.productId, textField: paymentsAmount.textField)
                    updateInfoButton(model.rates.value)
                    sendUpdateRates()
                    
                case let payload as ProductsSwapAction.Selected.To:
                    
                    updateAmountSwitch(to: payload.productId)
                    updateInfoButton(model.rates.value)
                    sendUpdateRates()
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
        
        $state
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] state in
                
                updateTransferButton(state)

            }.store(in: &bindings)
        
        paymentsAmount.textField.$text
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                
                updateTransferButton(.normal)
                updateInfoButton(model.rates.value)
                
            }.store(in: &bindings)
    }
    
    private func updateAmountSwitch(from id: ProductData.ID) {
        
        guard let productIdTo = swapViewModel.productIdTo else {
            return
        }
        
        updateAmountSwitch(from: id, to: productIdTo)
    }
    
    private func updateAmountSwitch(to id: ProductData.ID) {
        
        guard let productIdFrom = swapViewModel.productIdFrom else {
            return
        }
        
        updateAmountSwitch(from: productIdFrom, to: id)
    }
    
    private func updateAmountSwitch(from: ProductData.ID, to: ProductData.ID) {
        
        guard let products = Self.products(model, from: from, to: to) else {
            return
        }

        let currencyData = model.currencyList.value
        
        let fromItem = currencyData.first(where: { $0.code == products.from.currency })
        let toItem = currencyData.first(where: { $0.code == products.to.currency })
        
        guard let fromItem = fromItem,
              let toItem = toItem,
              let fromCurrencySymbol = fromItem.currencySymbol,
              let toCurrencySymbol = toItem.currencySymbol else {
            return
        }
        
        if fromCurrencySymbol == toCurrencySymbol {
            
            paymentsAmount.currencySwitch = nil
            
        } else {
            
            paymentsAmount.currencySwitch = .init(from: fromCurrencySymbol, to: toCurrencySymbol, icon: .init("Payments Refresh CW")) {
                self.swapViewModel.action.send(ProductsSwapAction.Button.Tap())
            }
        }
    }

    private func updateTransferButton(_ state: State) {
        
        switch state {
        case .normal:
            
            let value = paymentsAmount.textField.value
            
            let transferButton = PaymentsAmountView.ViewModel.makeTransferButton(value) { [weak self] in
                self?.action.send(PaymentsMeToMeAction.Button.Transfer.Tap())
            }
            
            paymentsAmount.transferButton = transferButton
            
        case .loading:
            
            paymentsAmount.transferButton = .loading(icon: .init("Logo Fora Bank"), iconSize: .init(width: 40, height: 40))
        }
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
    
    private func sendUpdateRates() {
        
        guard let productIdFrom = swapViewModel.productIdFrom,
              let productIdTo = swapViewModel.productIdTo,
              let products = Self.products(model, from: productIdFrom, to: productIdTo) else {
            return
        }

        let currencyFrom: Currency = .init(description: products.from.currency)
        let currencyTo: Currency = .init(description: products.to.currency)
        
        if currencyFrom == Currency.rub {
            
            model.action.send(ModelAction.Rates.Update.Single(currency: currencyTo))
            
        } else if currencyTo == Currency.rub {
            
            model.action.send(ModelAction.Rates.Update.Single(currency: currencyFrom))
            
        } else {
            
            model.action.send(ModelAction.Rates.Update.List(currencyList: [currencyTo, currencyFrom]))
        }
    }
    
    private func updateInfoButton(_ rates: [ExchangeRateData]) {
        
        guard let productIdFrom = swapViewModel.productIdFrom,
              let productIdTo = swapViewModel.productIdTo,
              let products = Self.products(model, from: productIdFrom, to: productIdTo) else {
            
            defaultInfoButton()
            return
        }
        
        if productIdFrom == productIdTo,
           products.from.currency == products.to.currency {
            
            defaultInfoButton()
            return
        }
        
        let currencyData = model.currencyList.value
        let amount = paymentsAmount.textField.value
        
        let currencyFrom: Currency = .init(description: products.from.currency)
        let currencyTo: Currency = .init(description: products.to.currency)
        
        let rateDataFrom = rates.first(where: { $0.currency == currencyFrom })
        let rateDataTo = rates.first(where: { $0.currency == currencyTo })
        
        let currencyDataFrom = currencyData.first(where: { $0.code == currencyFrom.description })
        let currencyDataTo = currencyData.first(where: { $0.code == currencyTo.description })
        
        guard let currencyDataFrom = currencyDataFrom,
              let currencyDataTo = currencyDataTo,
              let currencySymbolFrom = currencyDataFrom.currencySymbol,
              let currencySymbolTo = currencyDataTo.currencySymbol else {
            
            defaultInfoButton()
            return
        }
        
        if currencyFrom == Currency.rub {
            
            if let rateDataTo = rateDataTo {
                
                let rateSell = rateDataTo.rateSell.currencyFormatter(currencySymbolFrom)
                let text = "1 \(currencySymbolTo)  -  \(rateSell)"
                
                if amount == 0 {
                    
                    paymentsAmount.info = .text(text)
                                    
                } else {
                    
                    let rateSellCurrency = amount / rateDataTo.rateSell
                    let currencyAmount = rateSellCurrency.currencyFormatter(currencySymbolTo)
                    
                    let text = "\(currencyAmount)   |   \(text)"
                    
                    paymentsAmount.info = .text(text)
                }
                
            } else {
                
                defaultInfoButton()
            }
            
        } else if currencyTo == Currency.rub {
         
            if let rateDataFrom = rateDataFrom {
                
                let rateBuy = rateDataFrom.rateBuy.currencyFormatter(currencySymbolTo)
                let text = "1 \(currencySymbolFrom)  -  \(rateBuy)"
                
                if amount == 0 {
                    
                    paymentsAmount.info = .text(text)
                    
                } else {
                    
                    let rateBuyCurrency = amount * rateDataFrom.rateBuy
                    let currencyAmount = rateBuyCurrency.currencyFormatter(currencySymbolTo)
                    
                    let text = "\(currencyAmount)   |   \(text)"
                    
                    paymentsAmount.info = .text(text)
                }
                
            } else {
                
                defaultInfoButton()
            }
            
        } else {

            if let rateDataFrom = rateDataFrom, let rateDataTo = rateDataTo {
                
                let rateBuy = rateDataTo.rateBuy / rateDataFrom.rateBuy
                let rateBuyCurrency = rateBuy.currencyFormatter(currencySymbolFrom)
                
                let text = "1 \(currencySymbolTo)  -  \(rateBuyCurrency)"
                
                if amount == 0 {
                    
                    paymentsAmount.info = .text(text)
                    
                } else {
                    
                    let rateBuyCurrency = (amount * rateDataFrom.rateBuy) / rateDataTo.rateBuy
                    let currencyAmount = rateBuyCurrency.currencyFormatter(currencySymbolTo)

                    let text = "\(currencyAmount)   |   \(text)"

                    paymentsAmount.info = .text(text)
                }
            }
        }
    }
    
    private func defaultInfoButton() {
        paymentsAmount.info = .button(title: "Без комиссии", icon: .ic16Info, action: {})
    }
    
    private func makeAlert(_ error: ModelError) {

        var messageError: String?
        
        switch error {
        case let .emptyData(message):
            messageError = message
        case let .statusError(_, message):
            messageError = message
        case let .serverCommandError(error):
            messageError = error
            
        default:
            messageError = nil
        }

        guard let messageError = messageError else {
            return
        }

        alert = .init(
            title: "Ошибка",
            message: messageError,
            primary: .init(type: .default, title: "Ok") { [weak self] in
                self?.alert = nil
            })
    }
}

extension PaymentsMeToMeViewModel {
    
    static func reduce(products: [ProductData]) -> ProductData? {
        
        let filterredProducts = products.filter { product in
            
            switch product.productType {
            case .card:
                
                guard let product = product as? ProductCardData else {
                    return false
                }

                return product.status == .blockedByClient ? false : true

            case .account:
                
                guard let product = product as? ProductAccountData else {
                    return false
                }
                
                return product.status == .blockedByClient ? false : true

            default:
                return true
            }
        }
        
        return filterredProducts.first
    }
    
    static func productsId(_ model: Model, swapViewModel: ProductsSwapView.ViewModel) -> (from: ProductData.ID, to: ProductData.ID)? {
        
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
    
    static func products(_ model: Model, from: ProductData.ID, to: ProductData.ID) -> (from: ProductData, to: ProductData)? {
        
        let from = model.product(productId: from)
        let to = model.product(productId: to)
        
        guard let from = from, let to = to else {
            return nil
        }
        
        return (from, to)
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
        
        struct Failed: Action {}
    }
}

// MARK: - Mode

extension PaymentsMeToMeViewModel {
    
    enum Mode {
        
        case general
    }
}
