//
//  PaymentsAmountViewComponent.swift
//  ForaBank
//
//  Created by Константин Савялов on 14.02.2022.
//

import SwiftUI

extension PaymentsTaxesAmountView {
    
    class ViewModel: PaymentsParameterViewModel {
        
        @Published var value: Double?
        @Published var showInfo: Bool
        @Published var showBalanceAlert: Bool = false
        @Published var switchButton: SwitchCurrencyButtonViewModel?
        
        var currencyCodeFrom: String
        var currencyCodeTo: String? = nil
        
        var numberFormatter: NumberFormatter
        
        // TODO: showInfo: Bool сделать с моделью
        init(value: Double? = nil, showInfo: Bool = false, currencyCodeFrom: String, currencyCodeTo: String? = nil) {
            self.value = value
            self.showInfo = showInfo
            self.currencyCodeFrom = currencyCodeFrom
            self.currencyCodeTo = currencyCodeTo
            
            numberFormatter = NumberFormatter()
            numberFormatter = setupNumberFormatter(with: getSymbol(from: currencyCodeFrom))
        }
        
        init(value: Double? = nil, showInfo: Bool = false, currencysymbolFrom: String, currencysymbolTo: String? = nil, showBalanceAlert: Bool = false) {
            self.value = value
            self.showInfo = showInfo
            self.showBalanceAlert = showBalanceAlert
            self.currencyCodeFrom = "RUB"
            if let currencysymbolTo = currencysymbolTo {
                self.switchButton = SwitchCurrencyButtonViewModel(fromCurrency: currencysymbolFrom, toCurrency: currencysymbolTo)
            }
            numberFormatter = NumberFormatter()
            numberFormatter = setupNumberFormatter(with: currencysymbolFrom)
        }
        
        class SwitchCurrencyButtonViewModel: ObservableObject {
            
            @Published var fromCurrency: String
            @Published var toCurrency: String
            
            init(fromCurrency: String, toCurrency: String) {
                self.fromCurrency = fromCurrency
                self.toCurrency = toCurrency
            }
            
            var title: String {
                return fromCurrency + " ⇆ " + toCurrency
            }
            
        }
        
        func setupNumberFormatter(with symbol: String) -> NumberFormatter {
            
            let currencyFormatter = NumberFormatter()
            currencyFormatter.usesGroupingSeparator = true
            currencyFormatter.numberStyle = .currency
            currencyFormatter.locale = Locale(identifier: "ru_RU")
            currencyFormatter.currencySymbol = symbol
            currencyFormatter.maximumFractionDigits = 2
            
            return currencyFormatter
        }
        
        func getSymbol(from symbol: String = "") -> String {
            var resultString = ""
            let currArr = Dict.shared.currencyList
            currArr?.forEach({ currency in
                if currency.code == symbol {
                    var symbolArr = currency.cssCode?.components(separatedBy: "\\")
                    symbolArr?.removeFirst()
                    symbolArr?.forEach { singleSymbol in
                        if let charCode = UInt32(singleSymbol, radix: 16), let unicode = UnicodeScalar(charCode) {
                            let str = String(unicode)
                            resultString.append(str)
                        }
                        else {
                            print("invalid input")
                        }
                    }
                }
            })
            
            return resultString
        }
        
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

struct PaymentsTaxesAmountView: View {
    
    @ObservedObject var viewModel: PaymentsTaxesAmountView.ViewModel
    
    var body: some View {

        VStack(alignment: .leading, spacing: 8) {
            
            if viewModel.showBalanceAlert {
                HStack(alignment: .center) {
                    Spacer()
                    Text("Недостаточно средств")
                        .font(Font.custom("Inter-Regular", size: 14))
                        .foregroundColor(Color(hex: "#FFFFFF"))
                        .frame(height: 32)
                    Spacer()
                }
                .foregroundColor(.white)
                .background(Color(hex: "#FF9636"))
            }
            
            if viewModel.value != nil {
                Text("Сумма перевода")
                    .font(Font.custom("Inter-Regular", size: 12))
                    .foregroundColor(Color(hex: "#999999"))
                    .padding(.horizontal, 20)
                    .padding(.top, 3)
                
            } else {
                Spacer().frame(height: 8)
            }
            
            HStack(alignment: .center) {
                
                VStack(spacing: 4) {
                    
                    HStack (alignment: .center) {
                        
                        TextField("", value: $viewModel.value,
                                  formatter: viewModel.numberFormatter)
                            .placeholder(when: viewModel.value == nil) {
                                Text("Сумма перевода")
                                    .foregroundColor(Color(hex: "#999999"))
                                    .font(Font.custom("Inter-SemiBold", size: 14))
                            }
                            .foregroundColor(Color(hex: "#FFFFFF"))
                            .font(Font.custom("Inter-SemiBold", size: 24))
                            .keyboardType(.numberPad)
                        
                        if let switchButton = viewModel.switchButton {
                            Button {
                                print("Action Switch Currency")
                            } label: {
                                Text(switchButton.title)
                                    .font(Font.custom("Inter-Regular", size: 12))
                                    .foregroundColor(Color(hex: "#1C1C1C"))
                                    .padding(.horizontal, 8)
                                    .background(
                                        Capsule()
                                            .foregroundColor(.white)
                                            .frame(height: 24)
                                    )
                            }
                        }
                        
                    }
                    
                    Divider()
                        .background(Color(hex: "#EAEBEB"))
                    
                }
                
                Button {
                    print("Action Перевести")
                } label: {
                    Text("Перевести")
                        .font(Font.custom("Inter-Regular", size: 16))
                        .foregroundColor(viewModel.value == nil ? Color(hex: "#FFFFFF") : Color(hex: "#FFFFFF"))
                        .frame(width: 114, height: 40)
                }
                .disabled(viewModel.value == nil)
                .background(viewModel.value == nil ? Color(hex: "#D3D3D3") : Color(hex: "#FF3636"))
                .cornerRadius(8)
                
            }
            .padding(.horizontal, 20)
            
            if viewModel.showInfo {
                
                HStack(spacing: 8) {
                    Text("Возможна комиссия")
                        .font(Font.custom("Inter-Regular", size: 12))
                        .foregroundColor(Color(hex: "#999999"))
                    
                    Button {
                        print("Показываем инфо о комисии")
                    } label: {
                        Image("infoBlack")
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 14, height: 14)
                            .foregroundColor(Color(hex: "#999999"))
                    }
                    
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
            } else {
                Spacer()
                    .frame(height: 8)
            }
            
        }
        .background(Color(hex: "#3D3D45"))
        
    }
}


struct PaymentsTaxesAmountViewComponent_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            
            PaymentsTaxesAmountView(viewModel: .init(currencysymbolFrom: "₽"))
                .previewLayout(.fixed(width: 375, height: 160))
            
            PaymentsTaxesAmountView(viewModel: .init(value: 10.52, showInfo: false, currencysymbolFrom: "₽", showBalanceAlert: false))
                .previewLayout(.fixed(width: 375, height: 160))
            
            PaymentsTaxesAmountView(viewModel: .init(value: 1000.52, showInfo: false, currencysymbolFrom: "₽", showBalanceAlert: true))
                .previewLayout(.fixed(width: 375, height: 160))
            
            PaymentsTaxesAmountView(viewModel: .init(showInfo: true, currencysymbolFrom: "₽", showBalanceAlert: false))
                .previewLayout(.fixed(width: 375, height: 160))
            
            PaymentsTaxesAmountView(viewModel: .init(value: 100000, showInfo: true, currencysymbolFrom: "₽", currencysymbolTo: "$", showBalanceAlert: true))
                .previewLayout(.fixed(width: 375, height: 160))
        
        }
    }
    
}
