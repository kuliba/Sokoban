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
    
    class ViewModel: PaymentsParameterViewModel {
        
        @Published var title: String
        var textField: TextFieldFormatableView.ViewModel
        @Published var currencySwitch: CurrencySwitchViewModel?
        @Published var transferButton: TransferButtonViewModel
        @Published var info: InfoViewModel?
        @Published var alert: AlertViewModel?
        
        private let actionTitle: String
        private let action: () -> Void
        private var bindings = Set<AnyCancellable>()
        
        init(title: String, amount: Double, transferButton: TransferButtonViewModel, info: InfoViewModel? = nil, currencySwitch: CurrencySwitchViewModel? = nil, alert: AlertViewModel? = nil, formatter: NumberFormatter = .currency(with: "₽"), actionTitle: String = "", action: @escaping () -> Void = {}) {
            
            self.title = title
            self.textField = .init(value: amount, formatter: formatter, limit: 10)
            self.transferButton = transferButton
            self.info = info
            self.currencySwitch = currencySwitch
            self.alert = alert
            self.actionTitle = actionTitle
            self.action = action
            super.init(source: Payments.ParameterMock())
        }
        
        init(with parameterAmount: Payments.ParameterAmount, actionTitle: String, action: @escaping () -> Void) {
            
            self.title = parameterAmount.title
            self.textField = .init(type: .general, value: parameterAmount.amount, formatter: .currency(with: "₽"), limit: 10)
            self.transferButton = .inactive(title: "Перевести")
            self.info = nil
            self.currencySwitch = nil
            self.alert = nil
            self.actionTitle = actionTitle
            self.action = action
            
            super.init(source: parameterAmount)
            bind()
        }
        
        init(_ title: String, textField: TextFieldFormatableView.ViewModel, currencySwitch: CurrencySwitchViewModel? = nil, transferButton: TransferButtonViewModel, info: InfoViewModel? = nil,  alert: AlertViewModel? = nil, actionTitle: String = "", action: @escaping () -> Void = {}) {
            
            self.title = title
            self.textField = textField
            self.transferButton = transferButton
            self.info = info
            self.currencySwitch = currencySwitch
            self.alert = alert
            self.actionTitle = actionTitle
            self.action = action
            
            super.init(source: Payments.ParameterMock())
        }
        
        convenience init(_ value: Double = 0, productData: ProductData, transferAction: @escaping () -> Void, infoAction: @escaping () -> Void) {
            
            let currency = Currency(description: productData.currency)
            let textField: TextFieldFormatableView.ViewModel = .init(value, currencySymbol: currency.currencySymbol)
            
            self.init("Сумма перевода", textField: textField, transferButton: .active(title: "Перевести", action: transferAction), info: .button(title: "Без комиссии", icon: .ic16Info, action: infoAction))
        }

        func bind() {
            
            textField.$text
                .receive(on: DispatchQueue.main)
                .sink {[unowned self] _ in
                    
                    update(value: String(textField.value))
                    
                }.store(in: &bindings)
        }
        
        override var isValid: Bool {
            
            guard let parameterAmount = source as? Payments.ParameterAmount else { return false }
            
            return parameterAmount.validator.isValid(value: textField.value)
        }
        
        func updateTranferButton(isEnabled: Bool) {
            
            if isEnabled {
                
                transferButton = .active(title: actionTitle, action: action)
                
            } else {
                
                transferButton = .inactive(title: actionTitle)
            }
        }
        
        enum TransferButtonViewModel {
            
            case inactive(title: String)
            case active(title: String, action: () -> Void )
        }
        
        enum InfoViewModel {
            
            case button(title: String, icon: Image, action: () -> Void)
            case text(String)
        }
        
        struct CurrencySwitchViewModel {
            
            let from: String
            let to: String
            let icon: Image
            let action: () -> Void
        }
        
        struct AlertViewModel {
            
            let title: String
        }
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
                            .font(Font.custom("Inter-Regular", size: 12))
                            .foregroundColor(Color(hex: "#999999"))
                            .padding(.top, 4)
                        
                        HStack {
                            
                            TextFieldFormatableView(viewModel: viewModel.textField, font: .systemFont(ofSize: 24, weight: .semibold), textColor: .white, keyboardType: .decimalPad)
                                .frame(height: 24, alignment: .center)
                            
                            /*
                            TextField("", value: $viewModel.amount, formatter: viewModel.formatter)
                                .keyboardType(.decimalPad)
                                .font(Font.custom("Inter-SemiBold", size: 24))
                                .foregroundColor(Color(hex: "#FFFFFF"))
                             */
                            
                            if let currencySwitchViewModel = viewModel.currencySwitch {
                                
                                CurrencySwitchView(viewModel: currencySwitchViewModel)
                            }
                        }
                        
                        Divider()
                            .background(Color(hex: "#EAEBEB"))
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
            Color(hex: "#3D3D45")
                .edgesIgnoringSafeArea(.bottom))
    }
    
    struct TitleView: View {
        
        @Binding var title: String?
        
        var body: some View {
            
            if let title = title {
                
                Text(title)
                    .font(Font.custom("Inter-Regular", size: 12))
                    .foregroundColor(Color(hex: "#999999"))
                
            } else {
                
                Text("")
                    .font(Font.custom("Inter-Regular", size: 12))
                    .foregroundColor(Color(hex: "#999999"))
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
                        .foregroundColor(Color(hex: "#D3D3D3"))
                    
                    Text(title)
                        .font(Font.custom("Inter-Regular", size: 16))
                        .foregroundColor(Color(hex: "#FFFFFF"))
                }
                
            case .active(title: let title, action: let action):
                Button(action: action) {
                    
                    ZStack {
                        
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundColor(Color(hex: "#FF3636"))
                        
                        Text(title)
                            .font(Font.custom("Inter-Regular", size: 16))
                            .foregroundColor(Color(hex: "#FFFFFF"))
                    }
                }
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
                        .font(Font.custom("Inter-Regular", size: 12))
                        .foregroundColor(Color(hex: "#999999"))
                    
                    Button(action: action) {
                        
                        icon
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(Color(hex: "#999999"))
                            .frame(width: 14, height: 14)
                    }
                    
                }
                
            case .text(let text):
                Text(text)
                    .font(Font.custom("Inter-Regular", size: 12))
                    .foregroundColor(Color(hex: "#999999"))
            }
        }
    }
    
    struct CurrencySwitchView: View {
        
        let viewModel: PaymentsAmountView.ViewModel.CurrencySwitchViewModel
        
        var body: some View {
            
            Button(action: viewModel.action) {
                
                HStack(spacing: 0) {
                    
                    Text(viewModel.from)
                        .font(Font.custom("Inter-Regular", size: 12))
                        .foregroundColor(Color(hex: "#1C1C1C"))
                        .frame(width: 16, height: 16)
                    
                    viewModel.icon
                        .frame(width: 16, height: 16)
                    
                    Text(viewModel.to)
                        .font(Font.custom("Inter-Regular", size: 12))
                        .foregroundColor(Color(hex: "#1C1C1C"))
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
    
    struct AlertView: View {
        
        let viewModel: PaymentsAmountView.ViewModel.AlertViewModel
        
        var body: some View {
            
            ZStack {
                
                Color(hex: "#FF9636")
                Text(viewModel.title)
                    .font(Font.custom("Inter-Regular", size: 14))
                    .foregroundColor(Color(hex: "#FFFFFF"))
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
    
    static let empty = PaymentsAmountView.ViewModel(title: "Сумма перевода", amount: 0, transferButton: .inactive(title: "Перевести"))
    
    static let emptyInfo =  PaymentsAmountView.ViewModel(title: "Сумма перевода", amount: 0, transferButton: .inactive(title: "Перевести"), info: .button(title: "Возможна комиссия", icon: Image("infoBlack"), action: {}))
    
    static let amount = PaymentsAmountView.ViewModel(title: "Сумма перевода", amount: 1000, transferButton: .active(title: "Перевести", action: {}))
    
    static let amountZeroCurrencyInfo = PaymentsAmountView.ViewModel(title: "Сумма перевода", amount: 0, transferButton: .active(title: "Перевести", action: {}), info: .text("1$ - 72.72 ₽"), currencySwitch: .init(from: "₽", to: "$", icon: Image("Payments Refresh CW"), action: {}))
    
    static let amountCurrencyInfo = PaymentsAmountView.ViewModel(title: "Сумма перевода", amount: 10000.20, transferButton: .active(title: "Перевести", action: {}), info: .text("13.75 $   |   1$ - 72.72 ₽"), currencySwitch: .init(from: "₽", to: "$", icon: Image("Payments Refresh CW"), action: {}))
    
    static let amountCurrencyInfoAlert = PaymentsAmountView.ViewModel(title: "Сумма перевода", amount: 214.45, transferButton: .active(title: "Перевести", action: {}), info: .text("13.75 $   |   1$ - 72.72 ₽"), currencySwitch: .init(from: "₽", to: "$", icon: Image("Payments Refresh CW"), action: {}), alert: .init(title: "Недостаточно средств"))
    
    static let amountParameter: PaymentsAmountView.ViewModel = {
        
        let viewModel = PaymentsAmountView.ViewModel(with: .init(.init(id: UUID().uuidString, value: "100"), title: "Сумма перевода", currency: .init(description: "RUB"), validator: .init(minAmount: 1, maxAmount: 1000)), actionTitle: "Перевести", action: {})
        
        viewModel.updateTranferButton(isEnabled: true)
        
        return viewModel
    }()
}
