//
//  CurrencyExchangeConfirmationComponent.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 17.07.2022.
//

import SwiftUI
import Combine

//MARK: - ViewModel

extension CurrencyExchangeConfirmationView {
    
    class ViewModel: ObservableObject, CurrencyWalletItem {
        
        let id = UUID().uuidString
        let sum: String
        let commission: String
        let currencySum: String
        
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
                  let currencyPayeeCode = response.currencyPayee?.description else {
                return nil
            }
            
            sum = model.amountFormatted(amount: debitAmount,
                                             currencyCode: currencyPayerCode,
                                             style: .normal) ?? String(debitAmount)
            commission = model.amountFormatted(amount: fee,
                                                    currencyCode: currencyPayerCode,
                                                    style: .normal) ?? String(fee)
            currencySum = model.amountFormatted(amount: creditAmount,
                                                     currencyCode: currencyPayeeCode,
                                                     style: .normal) ?? String(creditAmount)
        }
    }
}

//MARK: - View

struct CurrencyExchangeConfirmationView: View {
    
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

// MARK: - Preview Content

extension CurrencyExchangeConfirmationView.ViewModel {
    
    static var sample = CurrencyExchangeConfirmationView.ViewModel(
        sum: "64,50 ₽",
        commission: "0,00 ₽",
        currencySum: "1 $")
}

//MARK: - Preview

struct CurrencyExchangeConfirmationView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        CurrencyExchangeConfirmationView(viewModel: .sample)
            .previewLayout(.fixed(width: 375, height: 160))
    }
}
