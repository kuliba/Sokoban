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
    @Published var sheet: Sheet?

    let swapViewModel: ProductsSwapView.ViewModel
    let paymentsAmount: PaymentsAmountView.ViewModel
        
    var title: String
    let mode: Mode
    
    private let model: Model
    private var bindings = Set<AnyCancellable>()
    
    enum State {
        
        case normal
        case loading
    }

    init(
        _ model: Model,
        swapViewModel: ProductsSwapView.ViewModel,
        paymentsAmount: PaymentsAmountView.ViewModel,
        title: String,
        mode: Mode = .general,
        state: State = .normal,
        bottomSheet: BottomSheet? = nil,
        sheet: Sheet? = nil
    ) {
        
        self.model = model
        self.swapViewModel = swapViewModel
        self.paymentsAmount = paymentsAmount
        self.title = title
        self.mode = mode
        self.state = state
        self.bottomSheet = bottomSheet
        self.sheet = sheet
        
        LoggerAgent.shared.log(level: .debug, category: .ui, message: "PaymentsMeToMeViewModel initialized")
    }
    
    deinit {
        
        LoggerAgent.shared.log(level: .debug, category: .ui, message: "PaymentsMeToMeViewModel deinitialized")
    }
    
    convenience init?(_ model: Model, mode: Mode) {
        
        guard let swapViewModel = ProductsSwapView.ViewModel(model, mode: mode) else {
            return nil
        }
        
        let amountViewModel = PaymentsAmountView.ViewModel(mode: mode, model: model)
        
        switch mode {
        case let .templatePayment(_, title):
            self.init(model, swapViewModel: swapViewModel, paymentsAmount: amountViewModel, title: title, mode: mode, state: .normal)
            
        default:
            self.init(model, swapViewModel: swapViewModel, paymentsAmount: amountViewModel, title: "Между своими", mode: mode, state: .normal)
        }
        
        bind()
    }
        
    private func bind() {
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                    
                case let payload as ModelAction.Settings.ApplicationSettings.Response:
                    
                    switch payload.result {
                        
                    case .success(let settings):
                        if settings.allowCloseDeposit, let productIdFrom = swapViewModel.productIdFrom, let productFrom = model.product(productId: productIdFrom) as? ProductDepositData, productFrom.isDemandDeposit {

                            let currencySymbol = model.dictionaryCurrencySymbol(for: productFrom.currency) ?? productFrom.currency

                            let alertViewModel = Alert.ViewModel(title: "Внимание",
                                                                 message: "Вклад будет закрыт автоматически.\nНеснижаемый остаток равен 1 \(currencySymbol).\nПроверьте сумму перевода.",
                                                                 primary: .init(type: .cancel, title: "Отмена", action: {}),
                                                                 secondary: .init(type: .default, title: "Перевести", action: {[weak self] in
                                guard let self = self, let productIdTo = self.swapViewModel.productIdTo, let productTo = self.model.product(productId: productIdTo) else {
                                    return
                                }

                                do {
                                    try self.model.sendCloseDepositRequest(productFrom: productFrom, productTo: productTo)
                                    self.state = .loading
                                } catch {
                                    LoggerAgent.shared.log(level: .error, category: .model, message: "Unable send close deposit request")
                                }
                                
                            }))
                            self.alert = .init(alertViewModel)
                            
                        } else {
                            
                            let alertViewModel = Alert.ViewModel(title: "Закрыть вклад",
                                                                 message: "Срок вашего вклада еще не истек. Для досрочного закрытия обратитесь в ближайший офис",
                                                                 primary: .init(type: .default, title: "Наши офисы", action: { [weak self] in self?.action.send(PaymentsMeToMeAction.Show.PlacesMap())}),
                                                                 secondary: .init(type: .default, title: "ОК", action: {}))
                            self.alert = .init(alertViewModel)
                        }
                        
                    case .failure(let error):
                        let alertViewModel = Alert.ViewModel(title: "Ошибка",
                                                             message: error.localizedDescription,
                                                             primary: .init(type: .default, title: "Наши офисы", action: { [weak self] in self?.action.send(PaymentsMeToMeAction.Show.PlacesMap())}),
                                                             secondary: .init(type: .default, title: "ОК", action: {}))
                        self.alert = .init(alertViewModel)
                    }
                    
                case let payload as ModelAction.Account.Close.Response:
                    
                    state = .normal

                    switch payload {
                    case let .success(data: transferData):

                        switch mode {
                        case let .closeAccount(productData, balance):
                            
                            let currency = Currency(description: productData.currency)
                            if let success = Payments.Success(
                                model: model,
                                mode: .closeAccount(
                                    productData.id,
                                    currency,
                                    balance: balance,
                                    transferData
                                ),
                                amountFormatter: model.amountFormatted(amount:currencyCode:style:)
                            ) {
                                
                                let successViewModel = PaymentsSuccessViewModel(paymentSuccess: success, model)
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
                    
                    
                case let payload as ModelAction.Deposits.Close.Response:
                    
                    state = .normal

                    switch payload {
                    case let .success(data: transferData):

                        switch mode {
                        case let .closeDeposit(productData, balance):
                            let currency = Currency(description: productData.currency)
                            if let success = Payments.Success(
                                model: model,
                                mode: .closeDeposit(
                                    currency,
                                    balance: balance,
                                    transferData
                                ),
                                amountFormatter: model.amountFormatted(amount:currencyCode:style:)
                            ) {
                                
                                let successViewModel = PaymentsSuccessViewModel(paymentSuccess: success, model)
                                self.action.send(PaymentsMeToMeAction.Response.Success(viewModel: successViewModel))
                            }
                            
                        case let .transferDeposit(productData, _), let .transferAndCloseDeposit(productData, _):
                            let currency = Currency(description: productData.currency)
                            let balance = productData.balanceValue
                            if let success = Payments.Success(
                                model: model,
                                mode: .closeDeposit(
                                    currency,
                                    balance: balance,
                                    transferData
                                ),
                                amountFormatter: model.amountFormatted(amount:currencyCode:style:)
                            ) {
                               
                                let successViewModel = PaymentsSuccessViewModel(paymentSuccess: success, model)
                                self.action.send(PaymentsMeToMeAction.Response.Success(viewModel: successViewModel))
                            }
                            
                        case .demandDeposit:
                            if let productIdFrom = swapViewModel.productIdFrom,
                               let productData = model.product(productId: productIdFrom) {
                                
                                let currency = Currency(description: productData.currency)
                                let balance = productData.balanceValue
                                
                                if let success = Payments.Success(
                                    model: model,
                                    mode: .closeDeposit(
                                        currency,
                                        balance: balance,
                                        transferData
                                    ),
                                    amountFormatter: model.amountFormatted(amount:currencyCode:style:)
                                ) {
                                   
                                    let successViewModel = PaymentsSuccessViewModel(paymentSuccess: success, model)
                                    self.action.send(PaymentsMeToMeAction.Response.Success(viewModel: successViewModel))
                                }
                            }
                        default:
                            break
                        }
                        
                    case let .failure(message: message):
                        
                        makeAlert(ModelError.serverCommandError(error: message))
                    }
                    
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
        
        // ME2ME Actions
        
        model.action
            .receive(on: DispatchQueue.main)
            .first { $0 is ModelAction.Payment.MeToMe.CreateTransfer.Response }
            .sink { [unowned self] action in
                if let payload = action as? ModelAction.Payment.MeToMe.CreateTransfer.Response {
                    handleCreateTransferResponse(payload)
                }
            }
            .store(in: &bindings)
        
        model.action
            .receive(on: DispatchQueue.main)
            .first { $0 is ModelAction.Payment.MeToMe.MakeTransfer.Response }
            .sink { [unowned self] action in
                if let payload = action as? ModelAction.Payment.MeToMe.MakeTransfer.Response {
                    handleMakeTransferResponse(payload)
                }
            }
            .store(in: &bindings)
        
        model.rates
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] rates in
                
                updateInfoButton(rates)
                
            }.store(in: &bindings)
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case _ as PaymentsMeToMeAction.Show.ChangeName:
                    guard case let .templatePayment(templateId, _) = mode else {
                        return
                    }

                    renameBottomSheet(
                        oldName: title,
                        templateId: templateId
                    )
                    
                case _ as PaymentsMeToMeAction.Show.PlacesMap:
                    guard let placesViewModel = PlacesViewModel(model) else {
                        return
                    }
                    sheet = .init(type: .placesMap(placesViewModel))
                    
                case _ as PaymentsMeToMeAction.Response.Success:
                    if let productIdFrom = swapViewModel.productIdFrom,
                       let productIdTo = swapViewModel.productIdTo,
                       let productFrom = model.product(productId: productIdFrom),
                       let productTo = model.product(productId: productIdTo)
                    {
                        model.reloadProducts(
                            productTo: productTo,
                            productFrom: productFrom
                        )
                    }
                    
                case _ as PaymentsMeToMeAction.Button.Transfer.Tap:
                    
                    switch mode {
                    case .general, .makePaymentTo, .makePaymentToDeposite, .templatePayment:
                        
                        if let productIdFrom = swapViewModel.productIdFrom,
                           let productIdTo = swapViewModel.productIdTo,
                           let productFrom = model.product(productId: productIdFrom) {
                            
                            if productIdFrom == productIdTo {
                                
                                makeAlert(.emptyData(message: "Счет списания совпадает со счетом зачисления. Выберите другой продукт"))
                                
                            } else {
                                
                                model.action.send(ModelAction.Payment.MeToMe.CreateTransfer.Request(
                                    amount: paymentsAmount.textField.value,
                                    currency: productFrom.currency,
                                    productFrom: productIdFrom,
                                    productTo: productIdTo))
                                
                                state = .loading
                            }
                        }

                    case .transferDeposit, .demandDeposit:
                        
                        if let productIdFrom = swapViewModel.productIdFrom,
                           let productIdTo = swapViewModel.productIdTo,
                           let productFrom = model.product(productId: productIdFrom) {
                            
                            if productIdFrom == productIdTo {
                                
                                makeAlert(.emptyData(message: "Счет списания совпадает со счетом зачисления. Выберите другой продукт"))
                                
                            } else {
                                
                                if let depositProduct = productFrom as? ProductDepositData {
                                
                                    if depositProduct.isDemandDeposit,
                                       depositProduct.allowDebit,
                                       paymentsAmount.textField.value == productFrom.balanceValue {
                                        
                                        // проверка разрешения закрытия вкладов
                                        self.model.action.send(
                                            ModelAction.Settings.ApplicationSettings.Request()
                                        )
                                        
                                    } else if depositProduct.allowDebit,
                                              !depositProduct.endDateNf {
                                        
                                        model.action.send(ModelAction.Payment.MeToMe.CreateTransfer.Request(
                                            amount: paymentsAmount.textField.value,
                                            currency: productFrom.currency,
                                            productFrom: productIdFrom,
                                            productTo: productIdTo))
                                        
                                        state = .loading
                                    }
                                    
                                } else {
                                    
                                    model.action.send(ModelAction.Payment.MeToMe.CreateTransfer.Request(
                                        amount: paymentsAmount.textField.value,
                                        currency: productFrom.currency,
                                        productFrom: productIdFrom,
                                        productTo: productIdTo))
                                    
                                    state = .loading
                                }
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
                                
                                guard let productFrom = productFrom as? ProductAccountData else {
                                    return
                                }
                                
                                model.action.send(ModelAction.Account.Close.Request(payload: .init(id: productFrom.id, name: productFrom.name, startDate: nil, endDate: nil, statementFormat: nil, accountId: nil, cardId: productTo.id)))
                                
                                state = .loading
                                
                            case .account:
                                
                                guard let productFrom = productFrom as? ProductAccountData else {
                                    return
                                }
                                
                                model.action.send(ModelAction.Account.Close.Request(payload: .init(id: productFrom.id, name: productFrom.name, startDate: nil, endDate: nil, statementFormat: nil, accountId: productTo.id, cardId: nil)))
                                
                                state = .loading
                                
                            default:
                                break
                            }
                        }
                        
                    case let .closeDeposit(productFrom, _), let .transferAndCloseDeposit(productFrom, _):
                        guard let to = swapViewModel.to,
                              let productViewModel = to.productViewModel,
                              let productTo = model.product(productId: productViewModel.id),
                              let productFrom = productFrom as? ProductDepositData else {
                            return
                        }
                        do {
                            try model.sendCloseDepositRequest(productFrom: productFrom, productTo: productTo)
                            state = .loading
                        }
                        catch {
                            LoggerAgent.shared.log(level: .error, category: .model, message: "Unable send close deposit request")
                        }
                    }
                    
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
                    
                    let productFrom = model.product(productId: productIdFrom)
                    updateProductSwitch(swapViewModel: swapViewModel, productFrom: productFrom, isSwapButtonEnabled: mode.isUserInterractionEnabled)
                    updateAmountSwitch(from: productIdFrom)
                    updateTextField(productIdFrom, textField: paymentsAmount.textField)
                    updateInfoButton(model.rates.value)
                    sendUpdateRates()
                    
                case let payload as ProductsSwapAction.Selected.From:
                    
                    let productFrom = model.product(productId: payload.productId)
                    updateProductSwitch(swapViewModel: swapViewModel, productFrom: productFrom, isSwapButtonEnabled: mode.isUserInterractionEnabled)
                    updateAmountSwitch(from: payload.productId)
                    updateTextField(payload.productId, textField: paymentsAmount.textField)
                    updateInfoButton(model.rates.value)
                    sendUpdateRates()
                    
                case let payload as ProductsSwapAction.Selected.To:
                    
                    let productTo = model.product(productId: payload.productId)
                    updateProductSwitch(swapViewModel: swapViewModel, productTo: productTo, isSwapButtonEnabled: mode.isUserInterractionEnabled)
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
    
    func bindRename(
        rename: TemplatesListViewModel.RenameTemplateItemViewModel
    ) {
        
        rename.action
            .compactMap { $0 as? TemplatesListViewModelAction.RenameSheetAction.SaveNewName }
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] payload in
                
                bottomSheet = nil
                
                title = payload.newName
                model.action.send(ModelAction.PaymentTemplate.Update.Requested
                    .init(name: payload.newName,
                          parameterList: nil,
                          paymentTemplateId: payload.itemId))
                model.action.send(ModelAction.PaymentTemplate.List.Requested())
                
            }.store(in: &bindings)
    }
    
    func renameBottomSheet(
        oldName: String,
        templateId: PaymentTemplateData.ID
    ) {
        
        let viewModel = TemplatesListViewModel.RenameTemplateItemViewModel(
            oldName: oldName,
            templateID: templateId
        )
        
        self.bottomSheet = .init(type: .rename(viewModel))
        self.bindRename(rename: viewModel)
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
    
    private func modeForSuccessView(templateId: Int?, productIdFrom: ProductData.ID?, productIdTo: ProductData.ID?, transferData: TransferResponseData) -> PaymentsSuccessViewModel.Mode {
        if let productIdFrom = productIdFrom,
           let _ = model.product(productId: productIdFrom) as? ProductDepositData {
            return .makePaymentFromDeposit(from: productIdFrom, to: productIdTo, transferData)
        }
        else if let productIdTo = productIdTo,
                let _ = model.product(productId: productIdTo) as? ProductDepositData {
                 return .makePaymentToDeposit(from: productIdFrom, to: productIdTo, transferData)
             }
        return .meToMe(templateId: templateId, from: productIdFrom, to: productIdTo, transferData)
    }
    
    private func isSwapEnabled(isSwapButtonEnabled: Bool, productFrom: ProductData?, productTo: ProductData?) -> Bool {
        if productFrom is ProductDepositData || productTo is ProductDepositData {
            return false
        }
        return isSwapButtonEnabled
    }
    
    private func updateProductSwitch(model: ProductsSwapView.ViewModel, productFrom: ProductData?, productTo: ProductData?, isSwapButtonEnabled: Bool) {
        model.divider.swapButton?.isSwapButtonEnabled = isSwapEnabled(isSwapButtonEnabled: isSwapButtonEnabled, productFrom: productFrom, productTo: productTo)
    }
    
    private func updateProductSwitch(swapViewModel: ProductsSwapView.ViewModel, productFrom: ProductData?, isSwapButtonEnabled: Bool){
        if let productIdTo = swapViewModel.productIdTo,
           let productTo = model.product(productId: productIdTo){
            updateProductSwitch(model: swapViewModel, productFrom: productFrom, productTo: productTo, isSwapButtonEnabled: isSwapButtonEnabled)
        }
        else {
            updateProductSwitch(model: swapViewModel, productFrom: productFrom, productTo: nil, isSwapButtonEnabled: isSwapButtonEnabled)
        }
    }
    
    private func updateProductSwitch(swapViewModel: ProductsSwapView.ViewModel, productTo: ProductData?, isSwapButtonEnabled: Bool){
        if let productIdFrom = swapViewModel.productIdFrom,
           let productFrom = model.product(productId: productIdFrom){
            updateProductSwitch(model: swapViewModel, productFrom: productFrom, productTo: productTo, isSwapButtonEnabled: isSwapButtonEnabled)
        }
        else {
            updateProductSwitch(model: swapViewModel, productFrom: nil, productTo: productTo, isSwapButtonEnabled: isSwapButtonEnabled)
        }
    }
    
    private func updateAmountSwitch(from: ProductData.ID, to: ProductData.ID) {
        
        guard let products = Self.products(model, from: from, to: to) else {
            
            paymentsAmount.currencySwitch = nil
            return
        }

        let currencyData = model.currencyList.value
        guard let fromItem = currencyData.first(where: { $0.code == products.from.currency }),
              let toItem = currencyData.first(where: { $0.code == products.to.currency }),
              let fromCurrencySymbol = fromItem.currencySymbol,
              let toCurrencySymbol = toItem.currencySymbol else {
            return
        }
        
        if fromCurrencySymbol == toCurrencySymbol {
            
            paymentsAmount.currencySwitch = nil
            
        } else {
            
            switch mode {
            case .demandDeposit:
                let isSwapEnabled = isSwapEnabled(isSwapButtonEnabled: mode.isUserInterractionEnabled, productFrom: products.from, productTo: products.to)

                paymentsAmount.currencySwitch = .init(from: fromCurrencySymbol, to: toCurrencySymbol, icon: .init("Payments Refresh CW"), isUserInteractionEnabled: isSwapEnabled) { [weak self] in
                    self?.swapViewModel.action.send(ProductsSwapAction.Button.Tap())
                }

            case .transferDeposit, .makePaymentToDeposite, .transferAndCloseDeposit:
                paymentsAmount.currencySwitch = .init(from: fromCurrencySymbol, to: toCurrencySymbol, icon: .init("Payments Refresh CW"), isUserInteractionEnabled: false) { [weak self] in
                    self?.swapViewModel.action.send(ProductsSwapAction.Button.Tap())
                }
            default:
                paymentsAmount.currencySwitch = .init(from: fromCurrencySymbol, to: toCurrencySymbol, icon: .init("Payments Refresh CW"), isUserInteractionEnabled: mode.isUserInterractionEnabled) { [weak self] in
                    self?.swapViewModel.action.send(ProductsSwapAction.Button.Tap())
                }
            }
        }
    }

    private func updateTransferButton(_ state: State) {
        
        if swapViewModel.productIdTo != nil, swapViewModel.productIdFrom != nil {
            
            switch state {
            case .normal:
                
                let value = paymentsAmount.textField.value
                
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
        else {
            paymentsAmount.transferButton = .inactive(title: "Перевести")
            
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
    
    // TODO: надо упростить
    // TODO: форматирование в отдельный компонент
    
    static func updatePaymentInfo(
        currencyFrom: Currency,
        currencyTo: Currency,
        rateDataTo: ExchangeRateData?,
        currencySymbolFrom: String,
        currencySymbolTo: String,
        amount: Double,
        rateDataFrom: ExchangeRateData?,
        setDefaultInfoButton: @escaping () -> Void,
        setText: @escaping (String) -> Void
    ) {
        
        if currencyFrom == Currency.rub && currencyTo == Currency.rub {
            
            setDefaultInfoButton()
        } else if currencyFrom == Currency.rub {
            
            if let rateDataTo = rateDataTo {
                
                let rateSell = rateDataTo.rateSell.currencyFormatter(currencySymbolFrom)
                let text = "1 \(currencySymbolTo)  -  \(rateSell)"
                
                if amount == 0 {
                    
                    setText(text)
                    
                } else {
                    
                    let rateSellCurrency = amount / rateDataTo.rateSell
                    let currencyAmount = rateSellCurrency.currencyFormatter(currencySymbolTo)
                    
                    let text = "\(currencyAmount)   |   \(text)"
                    
                    setText(text)
                }
                
            } else {
                
                setDefaultInfoButton()
            }
            
        } else if currencyTo == Currency.rub {
            
            if let rateDataFrom = rateDataFrom {
                
                let rateBuy = rateDataFrom.rateBuy.currencyFormatter(currencySymbolTo)
                let text = "1 \(currencySymbolFrom)  -  \(rateBuy)"
                
                if amount == 0 {
                    
                    setText(text)
                    
                } else {
                    
                    let rateBuyCurrency = amount * rateDataFrom.rateBuy
                    let currencyAmount = rateBuyCurrency.currencyFormatter(currencySymbolTo)
                    
                    let text = "\(currencyAmount)   |   \(text)"
                    
                    setText(text)
                }
                
            } else {
                
                setDefaultInfoButton()
            }
            
        } else {
            
            if let rateDataFrom = rateDataFrom, let rateDataTo = rateDataTo {
                
                let rateBuy = rateDataTo.rateBuy / rateDataFrom.rateBuy
                let rateBuyCurrency = rateBuy.currencyFormatter(currencySymbolFrom)
                
                let text = "1 \(currencySymbolTo)  -  \(rateBuyCurrency)"
                
                if amount == 0 {
                    
                    setText(text)
                    
                } else {
                    
                    let rateBuyCurrency = (amount * rateDataFrom.rateBuy) / rateDataTo.rateBuy
                    let currencyAmount = rateBuyCurrency.currencyFormatter(currencySymbolTo)
                    
                    let text = "\(currencyAmount)   |   \(text)"
                    
                    setText(text)
                }
            }
        }
    }
    
    // TODO: нужен рефакторинг!!!
    private func updateInfoButton(_ rates: [ExchangeRateData]) {
        
        guard let productIdFrom = swapViewModel.productIdFrom,
              let productIdTo = swapViewModel.productIdTo,
              let products = Self.products(model, from: productIdFrom, to: productIdTo) else {
            
            setDefaultInfoButton()
            return
        }
        
        if productIdFrom == productIdTo,
           products.from.currency == products.to.currency {
            
            setDefaultInfoButton()
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
            
            setDefaultInfoButton()
            return
        }
        
        Self.updatePaymentInfo(
            currencyFrom: currencyFrom,
            currencyTo: currencyTo,
            rateDataTo: rateDataTo,
            currencySymbolFrom: currencySymbolFrom,
            currencySymbolTo: currencySymbolTo,
            amount: amount,
            rateDataFrom: rateDataFrom,
            setDefaultInfoButton: setDefaultInfoButton,
            setText: { [weak self] in self?.paymentsAmount.info = .text($0) })
    }
    
    private func setDefaultInfoButton() {
        paymentsAmount.info = .button(title: "Без комиссии", icon: .ic16Info, action: { [weak self] in
            self?.action.send(PaymentsMeToMeAction.Button.Info.Tap())
        })
    }
    
    private func makeAlert(
        _ error: ModelError,
        isFromMeToMeCreateTransfer: Bool = false
    ) {
        
        guard let alertData = createAlertData(error, isFromMeToMeCreateTransfer: isFromMeToMeCreateTransfer) else {
            return
        }
        
        alert = .init(
            title: alertData.title,
            message: alertData.messageError,
            primary: .init(type: .default, title: "ОК") { [weak self] in
                
                self?.alert = nil
                if isFromMeToMeCreateTransfer {
                    
                    self?.action.send(PaymentsMeToMeAction.Close.BottomSheet())
                }
            })
    }
    
    func createAlertData(
        _ error: ModelError,
        isFromMeToMeCreateTransfer: Bool = false
    ) -> (title: String, messageError: String)? {
        
        var messageError: String?
        
        switch error {
        case let .emptyData(errorMessage):
            messageError = errorMessage
        case let .statusError(_, errorMessage):
            messageError = errorMessage
        case let .serverCommandError(errorMessage):
            messageError = errorMessage
        case .unauthorizedCommandAttempt:
            messageError = nil
        }
        
        guard let messageError = messageError else {
            return nil
        }
        
        if isFromMeToMeCreateTransfer {
            return (title: "Операция в обработке", messageError: "Проверьте её статус позже в истории операций.")
        }

        return (title: "Ошибка", messageError: messageError)
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
    
    func getTemplateId() -> Int? {
        
        switch mode {
        case let .templatePayment(templateId, _):
            return templateId
            
        default:
            return nil
        }
    }
    
    func handleCreateTransferResponse(_ payload: ModelAction.Payment.MeToMe.CreateTransfer.Response) {
        
        state = .normal

        switch payload.result {
        case let .success(response):
            
            // For currency transfers
            if response.needMake == true {
                
                model.action.send(ModelAction.Payment.MeToMe.MakeTransfer.Request(transferResponse: response))
                state = .loading
                
            } else {
                
                // For ruble transfers
                if response.needOTP == false {
                    
                    let mode = modeForSuccessView(
                        templateId: getTemplateId(),
                        productIdFrom: swapViewModel.productIdFrom,
                        productIdTo: swapViewModel.productIdTo,
                        transferData: response
                    )
                    guard let success = Payments.Success(
                        model: model,
                        mode: mode,
                        amountFormatter: model.amountFormatted(amount:currencyCode:style:)
                    ) else {
                        return
                    }
                    
                    let successViewModel = PaymentsSuccessViewModel(paymentSuccess: success, model)
                    self.action.send(PaymentsMeToMeAction.Response.Success(viewModel: successViewModel))
                    
                } else {
                    
                    self.action.send(PaymentsMeToMeAction.Response.Failed())
                }
                
            }
            
        case let .failure(error):
            
            switch error {
               
            case let .statusError(status, _):
                makeAlert(error, isFromMeToMeCreateTransfer: status == .timeout)
                
            default:
                makeAlert(error)
            }
        }
    }
    
    func handleMakeTransferResponse(_ payload: ModelAction.Payment.MeToMe.MakeTransfer.Response) {
        
        state = .normal

        switch payload.result {
        case let .success(transferData):
            let mode = modeForSuccessView(
                templateId: getTemplateId(),
                productIdFrom: swapViewModel.productIdFrom,
                productIdTo: swapViewModel.productIdTo,
                transferData: transferData
            )
            
            guard let success = Payments.Success(
                model: model,
                mode: mode,
                amountFormatter: model.amountFormatted(amount:currencyCode:style:)
            ) else {
                return
            }
            
            let successViewModel = PaymentsSuccessViewModel(paymentSuccess: success, model)
            self.action.send(PaymentsMeToMeAction.Response.Success(viewModel: successViewModel))

        case let .failure(error):
            
            switch error {
               
            case let .statusError(status, _):
                makeAlert(error, isFromMeToMeCreateTransfer: status == .timeout)
                
            default:
                makeAlert(error)
            }
        }
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
    
    enum Close {
        struct BottomSheet: Action {}
        struct Sheet: Action {}
    }
    
    enum Show {
        struct PlacesMap: Action {}
        struct ChangeName: Action {}
    }
    
}

// MARK: - Mode

extension PaymentsMeToMeViewModel {
    
    enum Mode: Equatable {
        
        case general
        case closeAccount(ProductData, Double)
        case closeDeposit(ProductData, Double)
        case makePaymentTo(ProductData, Double)
        case templatePayment(PaymentTemplateData.ID, String)
        case makePaymentToDeposite(ProductData, Double)
        case transferDeposit(ProductData, Double)
        case transferAndCloseDeposit(ProductData, Double)
        case demandDeposit

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
            case rename(TemplatesListViewModel.RenameTemplateItemViewModel)
        }
    }
    
    struct Sheet: Identifiable {
        
        let id = UUID()
        let type: Kind
        
        enum Kind {
            
            case placesMap(PlacesViewModel)
        }
    }
}

struct MeToMePayment: Equatable {
    
    private let amount: Double?
    private let payerProductId: Int
    private let payeeProductId: Int
    let templateId: Int?

    internal init(
        templateId: Int? = nil,
        payerProductId: Int,
        payeeProductId: Int,
        amount: Double?
    ) {
        
        self.templateId = templateId
        self.payerProductId = payerProductId
        self.payeeProductId = payeeProductId
        self.amount = amount
    }
    
    init?(mode: PaymentsSuccessViewModel.Mode) {

        switch mode {
        case let .meToMe(
            templateId: templateId,
            from: productFrom,
            to: productTo,
            transferData):
            
            guard let productFrom = productFrom,
                  let productTo = productTo else {
                return nil
            }
                    
            self.init(
                templateId: templateId,
                payerProductId: Int(productFrom),
                payeeProductId: Int(productTo),
                amount: transferData.amount
            )

        default:
            return nil
        }
    }
}
