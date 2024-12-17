//
//  PaymentsAmountViewComponent.swift
//  ForaBank
//
//  Created by Константин Савялов on 14.02.2022.
//

import SwiftUI
import Combine

// MARK: - ViewModel

extension PaymentsAmountView {
    
    class ViewModel: PaymentsParameterViewModel, PaymentsParameterViewModelContinuable, ObservableObject {
        
        @Published var title: String
        let textField: TextFieldFormatableView.ViewModel
        @Published var currencySwitch: CurrencySwitchViewModel?
        @Published var deliveryCurrency: DeliveryCurrencyViewModel?
        @Published var transferButton: TransferButtonViewModel
        @Published var info: InfoViewModel?
        @Published var alert: AlertViewModel?
        
        private var actionTitle: String
        private let buttonAction: () -> Void
        private let model: Model
        
        init(_ model: Model, title: String, textField: TextFieldFormatableView.ViewModel, currencySwitch: CurrencySwitchViewModel? = nil, deliveryCurrency: DeliveryCurrencyViewModel? = nil, transferButton: TransferButtonViewModel, info: InfoViewModel? = nil, alert: AlertViewModel? = nil, actionTitle: String = "", source: PaymentsParameterRepresentable = Payments.ParameterMock(), action: @escaping () -> Void = {}) {
            
            self.model = model
            self.title = title
            self.textField = textField
            self.transferButton = transferButton
            self.info = info
            self.currencySwitch = currencySwitch
            self.deliveryCurrency = deliveryCurrency
            self.alert = alert
            self.actionTitle = actionTitle
            self.buttonAction = action
            
            super.init(source: source)
            
            LoggerAgent.shared.log(level: .debug, category: .ui, message: "PaymentsAmountView.ViewModel initialized")
        }
        
        deinit {
            
            LoggerAgent.shared.log(level: .debug, category: .ui, message: "PaymentsAmountView.ViewModel deinitialized")
        }
        
        convenience init(with parameterAmount: Payments.ParameterAmount, model: Model) {
            
            self.init(model, title: parameterAmount.title, textField: .init(parameterAmount.amount, currencySymbol: parameterAmount.currencySymbol), transferButton: .inactive(title: parameterAmount.transferButtonTitle), actionTitle: parameterAmount.transferButtonTitle, source: parameterAmount)
            
            if let infoData = parameterAmount.info {
                
                info = .init(parameterInfo: infoData, action: { _ in

                    //TODO: implementation required
                    return {}
                })
            }
            
            if let deliveryCurrencyParams = parameterAmount.deliveryCurrency,
               let currency = model.currencyList.value.first(where: { $0.code == deliveryCurrencyParams.selectedCurrency.description }),
               let symbol = currency.currencySymbol {
                
                self.deliveryCurrency = .init(currency: symbol, action: { [weak self] in
                    
                    var items: [Option] = []
                    if let currencyList = deliveryCurrencyParams.currenciesList {
                        
                        for currency in currencyList {
                            
                            let currency = model.currencyList.value.first(where: { $0.code == currency.description })
                            items.append(.init(id: currency?.currencySymbol ?? "", name: currency?.name ?? ""))
                        }
                    }
                    
                    let viewModel = PaymentsPopUpSelectView.ViewModel(
                        title: "Выберите валюту выдачи",
                        description: nil,
                        options: items,
                        action: { [weak self] currency in
                            
                            if let currency = model.currencyList.value.first(where: { $0.currencySymbol == currency.description }),
                               let symbol = currency.currencySymbol {
                                
                                self?.deliveryCurrency?.currency = symbol
                                self?.action.send(PaymentsParameterViewModelAction.SelectSimple.PopUpSelector.Close())
                            }
                        }
                    )
                    self?.action.send(PaymentsParameterViewModelAction.SelectSimple.PopUpSelector.Show(viewModel: viewModel))
                })
            }
            
            bind()
            bind(textField: textField)
        }
        
        override var isValid: Bool {
            
            guard let parameterAmount = source as? Payments.ParameterAmount else { return false }
            
            return parameterAmount.validator.isValid(value: textField.value)
        }
        
        override var isValidationChecker: Bool { true }
        
        override func update(source: PaymentsParameterRepresentable) {
            super.update(source: source)
            
            guard let parameterAmount = source as? Payments.ParameterAmount else {
                return
            }
            
            let currency = self.model.currencyList.value.first(where: { $0.code == parameterAmount.deliveryCurrency?.selectedCurrency.description })
            textField.update(parameterAmount.amount, currencySymbol: currency?.currencySymbol ?? parameterAmount.currencySymbol)
            actionTitle = parameterAmount.transferButtonTitle
            
            if let deliveryCurrencyParams = parameterAmount.deliveryCurrency,
               let currency = model.currencyList.value.first(where: { $0.code == deliveryCurrencyParams.selectedCurrency.description }),
               let symbol = currency.currencySymbol {
                
                self.deliveryCurrency = .init(currency: symbol, action: { [weak self] in
                    
                    var items: [Option] = []
                    if let currencyList = deliveryCurrencyParams.currenciesList {
                        
                        for currency in currencyList {
                            
                            let currency = self?.model.currencyList.value.first(where: { $0.code == currency.description })
                            items.append(.init(id: currency?.currencySymbol ?? "", name: currency?.name ?? ""))
                        }
                    }
                    
                    if items.count > 1 {
                        
                        let viewModel = PaymentsPopUpSelectView.ViewModel(
                            title: "Выберите валюту выдачи",
                            description: nil,
                            options: items,
                            action: { [weak self] currency in
                                
                                if let currency = self?.model.currencyList.value.first(where: { $0.currencySymbol == currency.description }),
                                   let symbol = currency.currencySymbol {
                                    
                                    self?.deliveryCurrency?.currency = symbol
                                    self?.bind()
                                    self?.action.send(PaymentsParameterViewModelAction.SelectSimple.PopUpSelector.Close())
                                }
                            }
                        )
                        
                        self?.action.send(PaymentsParameterViewModelAction.SelectSimple.PopUpSelector.Show(viewModel: viewModel))
                    }
                })
            }
            
            if let infoData = parameterAmount.info {
                
                info = .init(parameterInfo: infoData, action: { _ in

                    //TODO: implementation required
                    return {}
                })
            }
        }
        
        func bind() {
            
            deliveryCurrency?.$currency
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] currency in
                    
                    guard let source = self.source as? Payments.ParameterAmount,
                          source.currencySymbol != self.deliveryCurrency?.currency else {
                        return
                    }
                    
                    guard let currencyList = source.deliveryCurrency?.currenciesList?.compactMap({ $0.description }) else {
                        return
                    }
                    
                    let filteredCurrency = self.model.currencyList.value.filter { currency in
                        
                        currencyList.contains(currency.code)
                    }
                    
                    if let currency = filteredCurrency.first(where: { $0.currencySymbol == currency.description }),
                       let currencySymbol = currency.currencySymbol {
                        
                        textField.update(source.amount, currencySymbol: currencySymbol)
                        
                        if let selectCurrencyUpdated = source.updated(value: source.amount.description, selectedCurrency: .init(description: currency.code)) as? Payments.ParameterAmount {
                            
                            update(source: selectCurrencyUpdated.updated(currencySymbol: currencySymbol))
                            updateCurrencyIsChanged(currencyIsChanged: true)
                            
                        } else {
                            
                            update(value: nil)
                        }
                    }
                }
                .store(in: &bindings)
        }
        
        func bind(textField: TextFieldFormatableView.ViewModel) {
            
            textField.$text
                .dropFirst()
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] _ in
                    
                    update(value: String(textField.value))
                    
                }
                .store(in: &bindings)
        }
        
        func update(isContinueEnabled: Bool) {
            
            if isContinueEnabled {
                
                transferButton = .active(
                    title: actionTitle,
                    action: { [weak self] in
                        
                        //TODO: remove
                        self?.buttonAction()
                        self?.action.send(PaymentsParameterViewModelAction.Amount.ContinueDidTapped())
                    }
                )
            } else {
                
                transferButton = .inactive(title: actionTitle)
            }
        }
    }
}

extension PaymentsAmountView.ViewModel {
    
    convenience init(
        mode: PaymentsMeToMeViewModel.Mode,
        model: Model,
        action: @escaping () -> Void = {}
    ) {
        func textFieldFactory(
            _ value: Double,
            isEnabled: Bool,
            currencySymbol: String
        ) -> TextFieldFormatableView.ViewModel {
            
            .init(value, isEnabled: isEnabled, currencySymbol: currencySymbol)
        }
        
        let currencySymbol = mode.currencySymbol(
            dictionaryCurrencySymbol: model.dictionaryCurrencySymbol(for:),
            productsTransfer: model.productsTransfer(templateId:)
        ) ?? ""
        let balance = mode.balance(
            productsTransfer: model.productsTransfer(templateId:)
        )
        let isEnabled = mode.isEnabled()
        let action = mode.shouldPassAction() ? action : {}
        
        let textField = textFieldFactory(balance, isEnabled: isEnabled, currencySymbol: currencySymbol)
        
        self.init(model, title: "Сумма перевода", textField: textField, transferButton: .inactive(title: "Перевести"), action: action)
    }
}

extension PaymentsMeToMeViewModel.Mode {
    
    typealias DictionaryCurrencySymbol = (String) -> String?
    typealias ProductsTransfer = (PaymentTemplateData.ID) -> (productTo: ProductData, productFrom: ProductData, amount: Double)?
    
    func currencySymbol(
        dictionaryCurrencySymbol: @escaping DictionaryCurrencySymbol,
        productsTransfer: @escaping ProductsTransfer
    ) -> String? {
        
        switch self {
        case .general, .demandDeposit:
            return dictionaryCurrencySymbol(Currency.rub.description)
            
        case
            let .closeAccount(productData, _),
            let .closeDeposit(productData, _),
            let .makePaymentTo(productData, _),
            let .makePaymentToDeposite(productData, _),
            let .transferAndCloseDeposit(productData, _),
            let .transferDeposit(productData, _):
            return dictionaryCurrencySymbol(productData.currency)
            
        case let .templatePayment(templateId, _):
            guard let (_, productFrom, _) = productsTransfer(templateId)
            else {
                return dictionaryCurrencySymbol(Currency.rub.description)
            }
            
            return dictionaryCurrencySymbol(productFrom.currency)
        }
    }
    
    func balance(
        productsTransfer: @escaping ProductsTransfer
    ) -> Double {
        
        switch self {
        case .general, .demandDeposit:
            return 0
            
        case
            let .closeAccount(_, balance),
            let .closeDeposit(_, balance),
            let .makePaymentTo(_, balance),
            let .makePaymentToDeposite(_, balance),
            let .transferDeposit(_, balance),
            let .transferAndCloseDeposit(_, balance):
            return balance
            
        case let .templatePayment(templateId, _):
            guard let (_, _, balance) = productsTransfer(templateId) else {
                return 0
            }
            
            return balance
        }
    }
    
    func isEnabled() -> Bool {
        
        switch self {
        case
                .demandDeposit,
                .general,
                .makePaymentTo,
                .makePaymentToDeposite,
                .templatePayment,
                .transferDeposit:
            return true
            
        case
                .closeAccount,
                .closeDeposit,
                .transferAndCloseDeposit:
            return false
        }
    }
    
    func shouldPassAction() -> Bool {
        
        switch self {
        case
                .closeAccount,
                .general,
                .demandDeposit:
            return false
            
        case
                .closeDeposit,
                .makePaymentTo,
                .makePaymentToDeposite,
                .templatePayment,
                .transferDeposit,
                .transferAndCloseDeposit:
            return true
        }
    }
}

// MARK: - Types

extension PaymentsAmountView.ViewModel {
    
    enum TransferButtonViewModel {
        
        case inactive(title: String)
        case active(title: String, action: () -> Void )
        case loading(icon: Image, iconSize: CGSize)
    }
    
    enum InfoViewModel {
        
        case button(title: String, icon: Image, action: () -> Void)
        case text(String)
        
        init(parameterInfo: Payments.ParameterAmount.Info, action: (Payments.ParameterAmount.Info.Action) -> () -> Void) {
            
            switch parameterInfo {
            case let .action(title: title, icon, infoAction):
                switch icon {
                case let .name(name):
                    self = .button(title: title, icon: Image(name), action: action(infoAction))
                    
                case let .image(image):
                    let iconImage = image.image ?? .ic24Info
                    self = .button(title: title, icon: iconImage, action: action(infoAction))
                }
            }
        }
    }
    
    class DeliveryCurrencyViewModel: ObservableObject {
        
        @Published var currency: String
        let action: () -> Void
        
        init(currency: String, action: @escaping () -> Void) {
            
            self.currency = currency
            self.action = action
        }
    }
    
    struct CurrencySwitchViewModel {
        
        let from: String
        let to: String
        let icon: Image
        let isUserInteractionEnabled: Bool
        let action: () -> Void
    }
    
    struct AlertViewModel {
        
        let title: String
    }
}

// MARK: - Action

extension PaymentsParameterViewModelAction {
    
    enum Amount {
    
        struct ContinueDidTapped: Action {}
    }
}

// MARK: - View

struct PaymentsAmountView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            if let alertViewModel = viewModel.alert {
                
                AlertView(viewModel: alertViewModel)
                    .frame(width: .infinity, height: 32)
            }
            
            Group {
                
                HStack(alignment: .bottom, spacing: 28) {
                    
                    VStack(alignment: .leading, spacing: 4) {
                        
                        Text(viewModel.title)
                            .font(.textBodySR12160())
                            .foregroundColor(.textPlaceholder)
                            .padding(.top, 4)
                            .accessibilityIdentifier("PaymentsAmountViewTitle")
                        
                        HStack {
                            
                            TextFieldFormatableView(
                                viewModel: viewModel.textField,
                                font: .systemFont(ofSize: 24, weight: .semibold),
                                textColor: .white,
                                keyboardType: .decimalPad
                            )
                            .frame(height: 24, alignment: .center)
                            .accessibilityIdentifier("PaymentsAmountViewInputField")
                            
                            viewModel.currencySwitch.map(CurrencySwitchView.init)
                            viewModel.deliveryCurrency.map(DeliveryCurrency.init)
                        }
                        
                        Divider()
                            .background(Color.bordersDivider)
                            .padding(.top, 4)
                        
                    }
                    
                    TransferButtonView(viewModel: viewModel.transferButton)
                        .frame(width: 113, height: 40)
                }
                
                if let infoViewModel = viewModel.info {
                    
                    InfoView(viewModel: infoViewModel)
                        .frame(height: 32)
                        .padding(.bottom)
                    
                } else {
                    
                    Color.clear
                        .frame(height: 32)
                }
            }
            .padding(.horizontal, 20)
        }
        .background(
            Color.mainColorsBlackMedium
                .ignoresSafeArea(.container, edges: .bottom)
        )
    }
    
    struct TitleView: View {
        
        @Binding var title: String?
        
        var body: some View {
            
            Text(title ?? "")
                .font(.textBodySR12160())
                .foregroundColor(.textPlaceholder)
        }
    }
    
    struct TransferButtonView: View {
        
        let viewModel: PaymentsAmountView.ViewModel.TransferButtonViewModel
        
        var body: some View {
            
            switch viewModel {
            case .inactive(title: let title):
                ZStack {
                    
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(.mainColorsGrayMedium.opacity(0.1))
                    
                    Text(title)
                        .font(.textH4R16240())
                        .foregroundColor(.mainColorsWhite.opacity(0.5))
                }
                .accessibilityIdentifier("PaymentAmountViewTransferButtonInactive")
                
            case .active(title: let title, action: let action):
                Button(action: action) {
                    
                    ZStack {
                        
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundColor(Color(hex: "#FF3636"))
                        
                        Text(title)
                            .font(.textH4R16240())
                            .foregroundColor(.textWhite)
                    }
                    .accessibilityIdentifier("PaymentAmountViewTransferButton")
                }
                
            case let .loading(icon: icon, iconSize: iconSize):
                SpinnerRefreshView(icon: icon, iconSize: iconSize)
            }
        }
    }
    
    struct InfoView: View {
        
        let viewModel: PaymentsAmountView.ViewModel.InfoViewModel
        
        var body: some View {
            
            switch viewModel {
            case .button(title: let title, icon: let icon, action: let action):
                HStack(spacing: 8) {
                    
                    Text(title)
                        .font(.textBodySR12160())
                        .foregroundColor(.textPlaceholder)
                        .accessibilityIdentifier("PaymentsAmountViewFeeSubtitle")
                    
                    Button(action: action) {
                        
                        icon
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(.textPlaceholder)
                            .frame(width: 14, height: 14)
                    }
                    
                }
                
            case .text(let text):
                Text(text)
                    .font(.textBodySR12160())
                    .foregroundColor(.textPlaceholder)
                    .accessibilityIdentifier("PaymentsAmountViewCurrencySubtitle")
            }
        }
    }
    
    struct DeliveryCurrency: View {
        
        @ObservedObject var viewModel: PaymentsAmountView.ViewModel.DeliveryCurrencyViewModel
        
        var body: some View {
            
            Button(action: { viewModel.action() }) {
                
                HStack(spacing: 0) {
                    
                    Text(viewModel.currency)
                        .font(.textBodySR12160())
                        .foregroundColor(.textSecondary)
                        .frame(width: 16, height: 16)
                    
                    Image.ic16ChevronDown
                        .frame(width: 16, height: 16)
                    
                }
                .padding(4)
                .background(
                    
                    Capsule()
                        .foregroundColor(.white)
                )
            }
            
        }
    }
    
    struct CurrencySwitchView: View {
        
        let viewModel: PaymentsAmountView.ViewModel.CurrencySwitchViewModel
        
        var body: some View {
            
            Button(action: viewModel.action) {
                
                HStack(spacing: 0) {
                    
                    Text(viewModel.from)
                        .font(.textBodySR12160())
                        .foregroundColor(.textSecondary)
                        .frame(width: 16, height: 16)
                        .accessibilityIdentifier("PaymentsAmountViewСurrencyFrom")
                    
                    viewModel.icon
                        .frame(width: 16, height: 16)
                        .accessibilityIdentifier("PaymentsAmountViewСurrencySwitchIcon")
                    
                    Text(viewModel.to)
                        .font(.textBodySR12160())
                        .foregroundColor(.textSecondary)
                        .frame(width: 16, height: 16)
                        .accessibilityIdentifier("PaymentsAmountViewСurrencyTo")
                    
                }
                .padding(4)
                .background(
                    
                    Capsule()
                        .foregroundColor(.white)
                )
            }
            .disabled(!viewModel.isUserInteractionEnabled)
            .accessibilityIdentifier("PaymentsAmountViewSwitchCurrencyButton")
        }
    }
    
    struct AlertView: View {
        
        let viewModel: PaymentsAmountView.ViewModel.AlertViewModel
        
        var body: some View {
            
            ZStack {
                //TODO: setup color after update lib
                Color(hex: "#FF9636")
                Text(viewModel.title)
                    .font(.textBodyMR14200())
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - Preview

struct PaymentsAmountView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            PaymentsAmountView(viewModel: .amountParameter)
            PaymentsAmountView(viewModel: .empty)
            PaymentsAmountView(viewModel: .emptyInfo)
            PaymentsAmountView(viewModel: .amount)
            PaymentsAmountView(viewModel: .amountZeroCurrencyInfo)
            PaymentsAmountView(viewModel: .amountCurrencyInfo)
            PaymentsAmountView(viewModel: .amountCurrencyInfoAlert)
        }
        .previewLayout(.fixed(width: 375, height: 160))
        .previewDisplayName("Parameter Amount")
    }
}

// MARK: - Preview Content

extension PaymentsAmountView.ViewModel {
    
    static let empty = PaymentsAmountView.ViewModel(.emptyMock, title: "Сумма перевода", textField: .init(0, currencySymbol: "₽"), transferButton: .inactive(title: "Перевести"))
    
    static let emptyInfo = PaymentsAmountView.ViewModel(.emptyMock, title: "Сумма перевода", textField: .init(0, currencySymbol: "₽"), transferButton: .inactive(title: "Перевести"), info: .button(title: "Возможна комиссия", icon: Image("infoBlack"), action: {}))
    
    static let amount = PaymentsAmountView.ViewModel(.emptyMock, title: "Сумма перевода", textField: .init(1000, currencySymbol: "₽"), transferButton: .active(title: "Перевести", action: {}))
    
    static let amountZeroCurrencyInfo = PaymentsAmountView.ViewModel(.emptyMock, title: "Сумма перевода", textField: .init(0, currencySymbol: "₽"), currencySwitch: .init(from: "₽", to: "$", icon: Image("Payments Refresh CW"), isUserInteractionEnabled: true, action: {}), transferButton: .active(title: "Перевести", action: {}), info: .text("1$ - 72.72 ₽"))
    
    static let amountCurrencyInfo = PaymentsAmountView.ViewModel(.emptyMock, title: "Сумма перевода", textField: .init(10000.20, currencySymbol: "₽"), currencySwitch: .init(from: "₽", to: "$", icon: Image("Payments Refresh CW"), isUserInteractionEnabled: true, action: {}), transferButton: .active(title: "Перевести", action: {}), info: .text("13.75 $   |   1$ - 72.72 ₽"))
    
    static let amountCurrencyInfoAlert = PaymentsAmountView.ViewModel(.emptyMock, title: "Сумма перевода", textField: .init(214.45, currencySymbol: "₽"), currencySwitch: .init(from: "₽", to: "$", icon: Image("Payments Refresh CW"), isUserInteractionEnabled: true, action: {}), transferButton: .active(title: "Перевести", action: {}), info: .text("13.75 $   |   1$ - 72.72 ₽"), alert: .init(title: "Недостаточно средств"))
    
    static let amountParameter: PaymentsAmountView.ViewModel = {
        
        let parameter = Payments.ParameterAmount(value: "100", title: "Сумма перевода", currencySymbol: "₽", validator: .init(minAmount: 1, maxAmount: 1000))
        let viewModel = PaymentsAmountView.ViewModel(with: parameter, model: .emptyMock)
        
        viewModel.update(isContinueEnabled: true)
        
        return viewModel
    }()
}
