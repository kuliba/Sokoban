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
    @Published var bottomSheet: BottomSheet?
    
    let swapViewModel: ProductsSwapView.ViewModel
    let paymentsAmount: PaymentsAmountView.ViewModel
        
    let title: String
    let mode: Mode
    
    private let model: Model
    private var bindings = Set<AnyCancellable>()
    
    enum State {
        
        case normal
        case loading
    }

    init(_ model: Model, swapViewModel: ProductsSwapView.ViewModel, paymentsAmount: PaymentsAmountView.ViewModel, title: String, mode: Mode = .general, state: State = .normal, bottomSheet: BottomSheet? = nil) {
        
        self.model = model
        self.swapViewModel = swapViewModel
        self.paymentsAmount = paymentsAmount
        self.title = title
        self.mode = mode
        self.state = state
        self.bottomSheet = bottomSheet
    }
    
    convenience init?(_ model: Model, mode: Mode) {
        
        guard let swapViewModel = ProductsSwapView.ViewModel(model, mode: mode) else {
            return nil
        }
        
        let amountViewModel = PaymentsAmountView.ViewModel(mode: mode, model: model)
        
        self.init(model, swapViewModel: swapViewModel, paymentsAmount: amountViewModel, title: "Между своими", mode: mode, state: .normal)
        
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
                            if response.needOTP == false {
                                
                                switch response.documentStatus {
                                case .complete:
                                    
                                    if let successViewModel = PaymentsSuccessViewModel(model, mode: .meToMe, transferData: response) {
                                        self.action.send(PaymentsMeToMeAction.Response.Success(viewModel: successViewModel))
                                    }

                                default:

                                    if let successViewModel = PaymentsSuccessViewModel(model, mode: .meToMe, productIdFrom: swapViewModel.productIdFrom, productIdTo: swapViewModel.productIdTo, transferData: response) {
                                        self.action.send(PaymentsMeToMeAction.Response.Success(viewModel: successViewModel))
                                    }
                                }
                                
                            } else {
                                
                                self.action.send(PaymentsMeToMeAction.Response.Failed())
                            }
                            
                            state = .normal
                        }
                        
                    case let .failure(error):
                        
                        state = .normal
                        makeAlert(error)
                    }
                    
                case let payload as ModelAction.Payment.MeToMe.MakeTransfer.Response:
                    
                    switch payload.result {
                    case let .success(transferData):
                        
                        if let successViewModel = PaymentsSuccessViewModel(model, mode: .meToMe, transferData: transferData) {
                            self.action.send(PaymentsMeToMeAction.Response.Success(viewModel: successViewModel))
                        }

                    case let .failure(error):
                        makeAlert(error)
                    }
                    
                    state = .normal

                case let payload as ModelAction.Account.Close.Response:
                    
                    switch payload {
                    case let .success(data: transferData):

                        switch mode {
                        case let .closeAccount(productData, balance):
                            
                            if let successViewModel = PaymentsSuccessViewModel(model, mode: .closeAccount(productData.id), currency: .init(description: productData.currency), balance: balance, transferData: transferData) {
                                
                                self.action.send(PaymentsMeToMeAction.Response.Success(viewModel: successViewModel))
                                makeInformer(closeAccount: true)
                            }
                            
                        default:
                            break
                        }
                        
                    case let .failure(message: message):
                        
                        makeAlert(ModelError.serverCommandError(error: message))
                        makeInformer(closeAccount: false)
                    }
                    
                    state = .normal
                    
                case let payload as ModelAction.Deposits.Close.Response:
                    switch payload {
                    case let .success(data: transferData):

                        switch mode {
                        case let .closeDeposit(productData, balance):
                            
                            if let successViewModel = PaymentsSuccessViewModel(model, mode: .closeDeposit, currency: .init(description: productData.currency), balance: balance, transferData: transferData) {
                                
                                self.action.send(PaymentsMeToMeAction.Response.Success(viewModel: successViewModel))
                            }
                            
                        default:
                            break
                        }
                        
                    case let .failure(message: message):
                        
                        makeAlert(ModelError.serverCommandError(error: message))
                    }
                    
                    state = .normal
                    
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
                    
                    switch mode {
                    case .general, .makePaymentTo:
                        
                        if let productIdFrom = swapViewModel.productIdFrom,
                           let productIdTo = swapViewModel.productIdTo,
                           let productFrom = model.product(productId: productIdFrom) {
                            
                            if productIdFrom == productIdTo {
                                
                                makeAlert(.emptyData(message: "Счет списания совпадает со счетом зачисления. Выберите другой продукт"))
                                
                            } else {
                                
                                state = .loading
                                
                                model.action.send(ModelAction.Payment.MeToMe.CreateTransfer.Request(
                                    amount: paymentsAmount.textField.value,
                                    currency: productFrom.currency,
                                    productFrom: productIdFrom,
                                    productTo: productIdTo))
                            }
                        }
                        
                    case let .closeAccount(productFrom, _):
                        
                        guard let to = swapViewModel.to,
                              let productViewModel = to.productViewModel,
                              let productTo = model.product(productId: productViewModel.id) else {
                            return
                        }
                        
                        if productFrom.id == productTo.id {
                            
                            makeAlert(.emptyData(message: "Счет списания совпадает со счетом зачисления. Выберите другой продукт"))
                            
                        } else {
                            
                            switch productTo.productType {
                            case .card:
                                
                                state = .loading
                                
                                guard let productFrom = productFrom as? ProductAccountData else {
                                    return
                                }
                                
                                model.action.send(ModelAction.Account.Close.Request(payload: .init(id: productFrom.id, name: productFrom.name, startDate: nil, endDate: nil, statementFormat: nil, accountId: nil, cardId: productTo.id)))
                                
                            case .account:
                                
                                state = .loading
                                
                                guard let productFrom = productFrom as? ProductAccountData else {
                                    return
                                }
                                
                                model.action.send(ModelAction.Account.Close.Request(payload: .init(id: productFrom.id, name: productFrom.name, startDate: nil, endDate: nil, statementFormat: nil, accountId: productTo.id, cardId: nil)))
                                
                            default:
                                break
                            }
                        }
                        
                    case let .closeDeposit(productFrom, _):
                        
                        guard let to = swapViewModel.to,
                              let productViewModel = to.productViewModel,
                              let productTo = model.product(productId: productViewModel.id) else {
                            return
                        }
                        
                        switch productTo.productType {
                            
                        case .card:

                            state = .loading

                            guard let productFrom = productFrom as? ProductDepositData, let productTo = productTo as? ProductCardData else {
                                return
                            }
                             
                            self.model.action.send(ModelAction.Deposits.Close.Request(payload: .init(id: productFrom.depositId, name: productFrom.productName, startDate: nil, endDate: nil, statementFormat: nil, accountId: nil, cardId: productTo.cardId)))
                            
                        case .account:

                            state = .loading

                            guard let productFrom = productFrom as? ProductDepositData else {
                                return
                            }
                                
                            self.model.action.send(ModelAction.Deposits.Close.Request(payload: .init(id: productFrom.depositId, name: productFrom.productName, startDate: nil, endDate: nil, statementFormat: nil, accountId: productTo.id, cardId: nil)))
                            
                        default:
                            break
                        }
                    }
                    
                    self.action.send(PaymentsMeToMeAction.InteractionEnabled(isUserInteractionEnabled: false))

                case _ as PaymentsMeToMeAction.Button.Info.Tap:
                    
                    switch mode {
                    case .closeDeposit(_, _):
                        self.bottomSheet = .init(type: .info(.init(icon: .ic48AlertCircle, title: "Сумма расcчитана автоматически с учетом условий по вашему вкладу")))

                    default:
                        break
                    }
                    
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
                    updateTransferButton(.normal)
                    sendUpdateRates()
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
        
        $state
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] state in
                
                switch state {
                case .normal: setUserInteractionEnabled(true)
                case .loading: setUserInteractionEnabled(false)
                }
                
                updateTransferButton(state)
                
            }.store(in: &bindings)
        
        paymentsAmount.textField.$text
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                
                updateTransferButton(.normal)
                updateInfoButton(model.rates.value)
                
            }.store(in: &bindings)
    }
    
    private func makeInformer(closeAccount: Bool) {
        
        if let productIdFrom = swapViewModel.productIdFrom,
           let product = model.product(productId: productIdFrom) {
            
            var message: String
            
            switch closeAccount {
            case true: message = "счет закрыт"
            case false: message = "счет не закрыт"
            }
            
            model.action.send(ModelAction.Informer.Show(informer: .init(message: "\(product.currency) \(message)", icon: .check)))
        }
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
    
    private func setUserInteractionEnabled(_ value: Bool) {
        
        self.action.send(PaymentsMeToMeAction.InteractionEnabled(isUserInteractionEnabled: value))
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
            
            paymentsAmount.currencySwitch = .init(from: fromCurrencySymbol, to: toCurrencySymbol, icon: .init("Payments Refresh CW"), isUserInteractionEnabled: mode.isUserInterractionEnabled) { [weak self] in
                self?.swapViewModel.action.send(ProductsSwapAction.Button.Tap())
            }
        }
    }

    private func updateTransferButton(_ state: State) {
        
        if swapViewModel.productIdTo == nil {
            return
        }
        
        switch state {
        case .normal:
            
            let value = paymentsAmount.textField.value
            
            //FIXME: is this correct logic?
            if value > 0 {
                
                paymentsAmount.transferButton = .active(title: "Перевести", action: { [weak self] in
                    self?.action.send(PaymentsMeToMeAction.Button.Transfer.Tap())
                })
                
            } else {
                
                paymentsAmount.transferButton = .inactive(title: "Перевести")
            }
            
        case .loading:
            
            paymentsAmount.transferButton = .loading(icon: .init("Logo Fora Bank"), iconSize: .init(width: 40, height: 40))
        }
    }

    private func updateTextField(_ id: ProductData.ID, textField: TextFieldFormatableView.ViewModel) {
        
        if let productData = model.product(productId: id) {
            
            let currencySymbol = model.dictionaryCurrencySymbol(for: productData.currency) ?? ""
            let formatter: NumberFormatter = .currency(with: currencySymbol)
            
            textField.formatter.currencySymbol = currencySymbol
            textField.text = formatter.string(from: .init(value: textField.value))

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
        
        if currencyFrom == Currency.rub && currencyTo == Currency.rub {
            paymentsAmount.info = nil
            
        } else if currencyFrom == Currency.rub {
            
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
        paymentsAmount.info = .button(title: "Без комиссии", icon: .ic16Info, action: { [weak self] in
            self?.action.send(PaymentsMeToMeAction.Button.Info.Tap())
        })
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
            
            let viewModel: PaymentsSuccessViewModel
        }
        
        struct Failed: Action {}
    }
    
    struct InteractionEnabled: Action {
        
        let isUserInteractionEnabled: Bool
    }
}

// MARK: - Mode

extension PaymentsMeToMeViewModel {
    
    enum Mode {
        
        case general
        case closeAccount(ProductData, Double)
        case closeDeposit(ProductData, Double)
        case makePaymentTo(ProductData, Double)
        
        var isUserInterractionEnabled: Bool {
            
            switch self {
            case .closeAccount, .closeDeposit:
                return false
                
            default:
                return true
            }
        }
    }
    
    struct BottomSheet: BottomSheetCustomizable {

        let id = UUID()
        let type: BottomSheetType

        enum BottomSheetType {

            case info(InfoView.ViewModel)
        }
    }
}
