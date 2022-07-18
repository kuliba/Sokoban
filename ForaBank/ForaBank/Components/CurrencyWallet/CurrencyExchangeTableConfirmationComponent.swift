//
//  CurrencyExchangeConfirmationComponent.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 17.07.2022.
//

import SwiftUI
import Combine

//MARK: - ViewModel

extension CurrencyExchangeTableConfirmationView {
    
    class ViewModel: ObservableObject {
        
        @Published var sum: String
        @Published var commission: String
        @Published var currencySum: String
        
        let sumLabel = "Сумма перевода"
        let commissionLabel = "Комиссия"
        let currencySumLabel = "Сумма зачисления в валюте"
        
        init(sum: String, commission: String, currencySum: String) {
            
            self.sum = sum
            self.commission = commission
            self.currencySum = currencySum
        }
        
        init?(response: CurrencyExchangeConfirmationData, model: Model) {
            
            guard let debitAmount = response.debitAmount,
                  let fee = response.fee,
                  let creditAmount = response.creditAmount,
                  let currencyPayerCode = response.currencyPayer?.description,
                  let currencyPayeeCode = response.currencyPayee?.description,
                  let currencyPayerItemDict = model.dictionaryCurrency(for: currencyPayerCode),
                  let currencyPayeeItemDict = model.dictionaryCurrency(for: currencyPayeeCode)
            else { return nil }
            
            self.sum = String(debitAmount)
            self.commission = String(fee)
            self.currencySum = String(creditAmount)
            
            if let currencyPayerChar = unicodeToString(currencyPayerItemDict.unicode) {
                
                self.sum += " " + currencyPayerChar
                self.commission += " " + currencyPayerChar
            }
            
            if let currencyPayeeChar = unicodeToString(currencyPayeeItemDict.unicode) {
                
                self.currencySum += " " + currencyPayeeChar
            }
            
        }
        
        private func unicodeToString(_ unicode: String?) -> String? {
            guard let unicode = unicode else { return nil }
            return unicode.replacingOccurrences(of: "\\", with: "")
                          .applyingTransform(.init("Hex/Unicode-Any"), reverse: false)
        }
    }
}

//MARK: - View

struct CurrencyExchangeTableConfirmationView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        ZStack {
            
            Color.mainColorsGrayLightest
                .cornerRadius(12)
            
            HStack {
                
                VStack(alignment: .leading, spacing: 12) {
                    
                    Text(viewModel.sumLabel)
                    Text(viewModel.commissionLabel)
                    Text(viewModel.currencySumLabel)
                }
                .font(.textBodyMR14200())
                .foregroundColor(.textPlaceholder)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 12) {
                    
                    Text(viewModel.sum)
                    Text(viewModel.commission)
                    Text(viewModel.currencySum)
                }
                .font(.textBodyMM14200())
                .foregroundColor(.textSecondary)
                
            }.padding(.horizontal, 20)
            
        }
        .frame(height: 124)
        .padding(.horizontal, 20)
    }
}

//MARK: - Preview

struct CurrencyExchangeTableConfirmationView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            CurrencyExchangeTableConfirmationView(viewModel: .sample)
                .previewLayout(.fixed(width: 375, height: 160))
        }
    }
}

extension CurrencyExchangeTableConfirmationView.ViewModel {
    
    static var sample = CurrencyExchangeTableConfirmationView
                            .ViewModel(sum: "64,50 \u{20BD}",
                                       commission: "0,00 \u{20BD}",
                                       currencySum: "1 $")
}


