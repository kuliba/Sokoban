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
        
        var courseChangeViewModel: CourseChangeViewModel?
        
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
                  let currencyPayee = response.currencyPayee,
                  let currencyRate = response.currencyRate else {
                return nil
            }
            
            sum = model.amountFormatted(amount: debitAmount,
                                        currencyCode: currencyPayerCode,
                                        style: .fraction) ?? String(debitAmount)
            
            commission = model.amountFormatted(amount: fee,
                                               currencyCode: currencyPayerCode,
                                               style: .fraction) ?? String(fee)
            
            currencySum = model.amountFormatted(amount: creditAmount,
                                                currencyCode: currencyPayeeCode,
                                                style: .fraction) ?? String(creditAmount)
            
            courseChangeViewModel = makeCourseChange(currency: currencyPayee, currencyRate: currencyRate)
        }
    }
}

extension CurrencyExchangeConfirmationView.ViewModel {
    
    private func makeCourseChange(currency: Currency, currencyRate: Double) -> CurrencyExchangeConfirmationView.CourseChangeViewModel? {
        
        guard currencyRate > 0 else {
            return nil
        }
        
        return .init(currency: currency, currencyRate: currencyRate)
    }
}

extension CurrencyExchangeConfirmationView {
    
    // MARK: - CourseChange
    
    class CourseChangeViewModel: ObservableObject {
        
        let currency: Currency
        let currencyRate: Double
        let icon: Image
        
        var title: String {
            "Курс изменился 1\(currency.description) = \(currencyRate), мы пересчитали сумму операции"
        }
        
        init(currency: Currency, currencyRate: Double, icon: Image = .init("Warning Course")) {
            
            self.currency = currency
            self.currencyRate = currencyRate
            self.icon = icon
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
            
            VStack(spacing: 16) {
                
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
        }
        .frame(height: 124)
        .padding(.horizontal, 20)
    }
}

extension CurrencyExchangeConfirmationView {
    
    // MARK: - CourseChange
    
    struct CourseChangeView: View {
        
        @ObservedObject var viewModel: CourseChangeViewModel
        
        var body: some View {
            
            HStack {
                
                viewModel.icon
                    .resizable()
                    .frame(width: 16, height: 16)
                
                Text(viewModel.title)
                    .font(.textBodyMR14200())
                    .foregroundColor(.systemColorWarning)
            }
        }
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
