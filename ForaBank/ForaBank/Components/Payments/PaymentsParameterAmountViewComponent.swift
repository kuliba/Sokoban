//
//  PaymentsParameterAmountViewComponent.swift
//  ForaBank
//
//  Created by Константин Савялов on 14.02.2022.
//

import SwiftUI
import Combine

//MARK: - ViewModel

extension PaymentsParameterAmountView {
    
    class ViewModel: PaymentsParameterViewModel {
        
        let description: String
        @Published var content: String
        @Published var transferButton: TransferButtonViewModel
        @Published var info: InfoViewModel?
        @Published var currencySwitch: CurrencySwitchViewModel?
        @Published var alert: AlertViewModel?
        @Published var title: String?
        
        private var bindings = Set<AnyCancellable>()
        
        init(description: String, content: String, transferButton: TransferButtonViewModel, info: InfoViewModel? = nil, currencySwitch: CurrencySwitchViewModel? = nil, alert: AlertViewModel? = nil, parameter: Payments.Parameter = .init(id: UUID().uuidString, value: "")) {
            
            self.description = description
            self.content = content
            self.transferButton = transferButton
            self.info = info
            self.currencySwitch = currencySwitch
            self.alert = alert
            super.init(parameter: parameter)
            
            bind()
        }
        
        private func bind() {
            
            $content
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] content in
                    
                    withAnimation(.easeInOut(duration: 0.2)) {
                        
                        title = content.count > 0 ? description : nil
                    }
                    
                }.store(in: &bindings)
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

struct PaymentsParameterAmountView: View {
    
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
                        
                        if let title = viewModel.title {
                            
                            Text(title)
                                .font(Font.custom("Inter-Regular", size: 12))
                                .foregroundColor(Color(hex: "#999999"))
                                .padding(.top, 4)
                            
                        } else {
                            
                            Color.clear
                                .frame(height: 16)
                        }
                        
                        HStack {
                            
                            ZStack(alignment: .leading) {
                                
                                if viewModel.title == nil {
                                    
                                    Text(viewModel.description)
                                        .font(Font.custom("Inter-Regular", size: 12))
                                        .foregroundColor(Color(hex: "#999999"))
                                }
                                
                                TextField(viewModel.description, text: $viewModel.content)
                                    .font(Font.custom("Inter-SemiBold", size: 24))
                                    .foregroundColor(Color(hex: "#FFFFFF"))
                                    .keyboardType(.numberPad)
                            }
                            
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
                    
                } else {
                    
                    Color.clear
                        .frame(height: 32)
                }
                
            }.padding(.horizontal, 20)
             
        }
        .background(Color(hex: "#3D3D45"))
        
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
        
        let viewModel: PaymentsParameterAmountView.ViewModel.TransferButtonViewModel
        
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
        
        let viewModel: PaymentsParameterAmountView.ViewModel.InfoViewModel
        
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
        
        let viewModel: PaymentsParameterAmountView.ViewModel.CurrencySwitchViewModel
        
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
        
        let viewModel: PaymentsParameterAmountView.ViewModel.AlertViewModel
        
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

struct PaymentsParameterAmountView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            PaymentsParameterAmountView(viewModel: .empty)
                .previewLayout(.fixed(width: 375, height: 160))
            
            PaymentsParameterAmountView(viewModel: .emptyInfo)
                .previewLayout(.fixed(width: 375, height: 160))
            
            PaymentsParameterAmountView(viewModel: .amount)
                .previewLayout(.fixed(width: 375, height: 160))
            
            PaymentsParameterAmountView(viewModel: .amountZeroCurrencyInfo)
                .previewLayout(.fixed(width: 375, height: 160))
            
            PaymentsParameterAmountView(viewModel: .amountCurrencyInfo)
                .previewLayout(.fixed(width: 375, height: 160))
            
            PaymentsParameterAmountView(viewModel: .amountCurrencyInfoAlert)
                .previewLayout(.fixed(width: 375, height: 160))
            
        }
    }
}

//MARK: - Preview Content

extension PaymentsParameterAmountView.ViewModel {
    
    static let empty = PaymentsParameterAmountView.ViewModel(description: "Сумма перевода", content: "", transferButton: .inactive(title: "Перевести"))
    
    static let emptyInfo =  PaymentsParameterAmountView.ViewModel(description: "Сумма перевода", content: "", transferButton: .inactive(title: "Перевести"), info: .button(title: "Возможна комиссия", icon: Image("infoBlack"), action: {}))
    
    static let amount = PaymentsParameterAmountView.ViewModel(description: "Сумма перевода", content: "1 000 ₽", transferButton: .active(title: "Перевести", action: {}))
    
    static let amountZeroCurrencyInfo = PaymentsParameterAmountView.ViewModel(description: "Сумма перевода", content: "0 ₽", transferButton: .active(title: "Перевести", action: {}), info: .text("1$ - 72.72 ₽"), currencySwitch: .init(from: "₽", to: "$", icon: Image("Payments Refresh CW"), action: {}))
    
    static let amountCurrencyInfo = PaymentsParameterAmountView.ViewModel(description: "Сумма перевода", content: "1 000 ₽", transferButton: .active(title: "Перевести", action: {}), info: .text("13.75 $   |   1$ - 72.72 ₽"), currencySwitch: .init(from: "₽", to: "$", icon: Image("Payments Refresh CW"), action: {}))
    
    static let amountCurrencyInfoAlert = PaymentsParameterAmountView.ViewModel(description: "Сумма перевода", content: "1 000 ₽", transferButton: .active(title: "Перевести", action: {}), info: .text("13.75 $   |   1$ - 72.72 ₽"), currencySwitch: .init(from: "₽", to: "$", icon: Image("Payments Refresh CW"), action: {}), alert: .init(title: "Недостаточно средств"))
    
}
