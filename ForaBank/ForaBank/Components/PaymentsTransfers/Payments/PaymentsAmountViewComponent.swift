//
//  PaymentsAmountViewComponent.swift
//  ForaBank
//
//  Created by Константин Савялов on 14.02.2022.
//

import SwiftUI
import Combine

//MARK: - ViewModel

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
               let currency = model.currencyList.value.first(where: {$0.code == deliveryCurrencyParams.selectedCurrency.description}),
               let symbol = currency.currencySymbol {
                
                self.deliveryCurrency = .init(currency: symbol, action: { [weak self] in
                    
                    var items: [Option] = []
                    if let currencyList = deliveryCurrencyParams.currenciesList {
                     
                        for currency in currencyList {
                         
                            let currency = model.currencyList.value.first(where: {$0.code == currency.description})
                            items.append(.init(id: currency?.currencySymbol ?? "", name: currency?.name ?? ""))
                        }
                    }
                    
                    self?.action.send(PaymentsParameterViewModelAction.SelectSimple.PopUpSelector.Show(viewModel: .init(title: "Выберите валюту выдачи", description: nil, options: items, action: { [weak self] currency in
                        
                        if let currency = model.currencyList.value.first(where: {$0.currencySymbol == currency.description}),
                           let symbol = currency.currencySymbol {
                            
                            self?.deliveryCurrency?.currency = symbol
                            
                            if let source = self?.source as? Payments.ParameterAmount {
                                
                                self?.update(source: parameterAmount.updated(value: source.value, selectedCurrency: Currency(description: currency.code)))
                            }
                            self?.action.send(PaymentsParameterViewModelAction.SelectSimple.PopUpSelector.Close())
                        }
                    })))
                })
            }
            
            bind(textField: textField)
        }

        convenience init(mode: PaymentsMeToMeViewModel.Mode, model: Model, action: @escaping () -> Void = {}) {
 
            switch mode {
            case .general, .demandDeposit:
                let currencySymbol = model.dictionaryCurrencySymbol(for: Currency.rub.description) ?? ""
                let textField = TextFieldFormatableView.ViewModel(0, currencySymbol: currencySymbol)
 
                self.init(model, title: "Сумма перевода", textField: textField, transferButton: .inactive(title: "Перевести"))
                
            case let .closeAccount(productData, balance):
                
                let currencySymbol = model.dictionaryCurrencySymbol(for: productData.currency) ?? ""
                let textField: TextFieldFormatableView.ViewModel = .init(balance, isEnabled: false, currencySymbol: currencySymbol)
                
                self.init(model, title: "Сумма перевода", textField: textField, transferButton: .inactive(title: "Перевести"))
                
            case let .closeDeposit(productData, balance):
                
                let currencySymbol = model.dictionaryCurrencySymbol(for: productData.currency) ?? ""
                let textField: TextFieldFormatableView.ViewModel = .init(balance, isEnabled: false, currencySymbol: currencySymbol)
                
                self.init(model, title: "Сумма перевода", textField: textField, transferButton: .inactive(title: "Перевести"), action: action)
                
            case let .makePaymentTo(productData, amount):
                let currencySymbol = model.dictionaryCurrencySymbol(for: productData.currency) ?? ""
                let textField: TextFieldFormatableView.ViewModel = .init(amount, isEnabled: true, currencySymbol: currencySymbol)
                
                self.init(model, title: "Сумма перевода", textField: textField, transferButton: .inactive(title: "Перевести"), action: action)
                
            case let .makePaymentToDeposite(productData, amount), let .transferDeposit(productData, amount):
                let currencySymbol = model.dictionaryCurrencySymbol(for: productData.currency) ?? ""
                let textField: TextFieldFormatableView.ViewModel = .init(amount, isEnabled: true, currencySymbol: currencySymbol)
                
                self.init(model, title: "Сумма перевода", textField: textField, transferButton: .inactive(title: "Перевести"), action: action)
                
            case let .transferAndCloseDeposit(productData, amount):
                let currencySymbol = model.dictionaryCurrencySymbol(for: productData.currency) ?? ""
                let textField: TextFieldFormatableView.ViewModel = .init(amount, isEnabled: false, currencySymbol: currencySymbol)
                
                self.init(model, title: "Сумма перевода", textField: textField, transferButton: .inactive(title: "Перевести"), action: action)
            }
        }

        func bind(textField: TextFieldFormatableView.ViewModel) {
            
            textField.$text
                .dropFirst()
                .receive(on: DispatchQueue.main)
                .sink {[unowned self] _ in
                    
                    update(value: String(textField.value))
                    
                }.store(in: &bindings)
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
            
            let currency = self.model.currencyList.value.first(where: {$0.code == parameterAmount.deliveryCurrency?.selectedCurrency.description})
            textField.update(parameterAmount.amount, currencySymbol: currency?.currencySymbol ?? parameterAmount.currencySymbol)
            actionTitle = parameterAmount.transferButtonTitle
            
            if let infoData = parameterAmount.info {
                
                info = .init(parameterInfo: infoData, action: { _ in

                    //TODO: implementation required
                    return {}
                })
            }
        }
        
        func update(isContinueEnabled: Bool) {
            
            if isContinueEnabled == true {
                
                transferButton = .active(title: actionTitle, action: { [weak self] in
                    
                    //TODO: remove
                    self?.buttonAction()
                    self?.action.send(PaymentsParameterViewModelAction.Amount.ContinueDidTapped())
                })
                
            } else {
                
                transferButton = .inactive(title: actionTitle)
            }
        }
    }
}

//MARK: - Types

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
    
    struct DeliveryCurrencyViewModel {
        
        var currency: String
        let action: () -> Void
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

//MARK: - Action

extension PaymentsParameterViewModelAction {
    
    enum Amount {
    
        struct ContinueDidTapped: Action {}
    }
}

//MARK: - View

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
                        
                        HStack {
                            
                            TextFieldFormatableView(viewModel: viewModel.textField, font: .systemFont(ofSize: 24, weight: .semibold), textColor: .white, keyboardType: .decimalPad)
                                .frame(height: 24, alignment: .center)
                            
                            if let currencySwitchViewModel = viewModel.currencySwitch {
                                
                                CurrencySwitchView(viewModel: currencySwitchViewModel)
                            }
                            
                            if let deliveryCurrency = viewModel.deliveryCurrency {
                                
                                DeliveryCurrency(viewModel: deliveryCurrency)
                            }
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
                
            }.padding(.horizontal, 20)
             
        }
        .background(
            Color.mainColorsBlackMedium
                .ignoresSafeArea(.container, edges: .bottom))
    }
    
    struct TitleView: View {
        
        @Binding var title: String?
        
        var body: some View {
            
            if let title = title {
                
                Text(title)
                    .font(.textBodySR12160())
                    .foregroundColor(.textPlaceholder)
                
            } else {
                
                Text("")
                    .font(.textBodySR12160())
                    .foregroundColor(.textPlaceholder)
            }
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
                
            case .active(title: let title, action: let action):
                Button(action: action) {
                    
                    ZStack {
                        
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundColor(Color(hex: "#FF3636"))
                        
                        Text(title)
                            .font(.textH4R16240())
                            .foregroundColor(.textWhite)
                    }
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
            }
        }
    }
    
    struct DeliveryCurrency: View {
        
        let viewModel: PaymentsAmountView.ViewModel.DeliveryCurrencyViewModel
        
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
                    
                    viewModel.icon
                        .frame(width: 16, height: 16)
                    
                    Text(viewModel.to)
                        .font(.textBodySR12160())
                        .foregroundColor(.textSecondary)
                        .frame(width: 16, height: 16)
                    
                }
                .padding(4)
                .background(
                    
                    Capsule()
                        .foregroundColor(.white)
                )
                
            }.disabled(viewModel.isUserInteractionEnabled == false)
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

//MARK: - Preview

struct PaymentsAmountView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {

            PaymentsAmountView(viewModel: .amountParameter)
                .previewLayout(.fixed(width: 375, height: 160))
                .previewDisplayName("Parameter Amount")
            
            PaymentsAmountView(viewModel: .empty)
                .previewLayout(.fixed(width: 375, height: 160))
            
            PaymentsAmountView(viewModel: .emptyInfo)
                .previewLayout(.fixed(width: 375, height: 160))
            
            PaymentsAmountView(viewModel: .amount)
                .previewLayout(.fixed(width: 375, height: 160))
            
            PaymentsAmountView(viewModel: .amountZeroCurrencyInfo)
                .previewLayout(.fixed(width: 375, height: 160))
            
            PaymentsAmountView(viewModel: .amountCurrencyInfo)
                .previewLayout(.fixed(width: 375, height: 160))
            
            PaymentsAmountView(viewModel: .amountCurrencyInfoAlert)
                .previewLayout(.fixed(width: 375, height: 160))
            
        }
    }
}

//MARK: - Preview Content

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
