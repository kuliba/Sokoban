//
//  CurrencyExchangeViewComponent.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 04.03.2022.
//

import SwiftUI

//MARK: - ViewModel

extension CurrencyExchangeView {
    
    struct ViewModel {

        let currencyRate: [CurrencyRate]
        let currencyLabel: String
        let buyLabel: String
        let sellLabel: String
        
        internal init(currencyRate: [CurrencyRate], currencyLabel: String = "Валюта", buyLabel: String = "Купить", sellLabel: String = "Продать") {

            self.currencyRate = currencyRate
            self.currencyLabel = currencyLabel
            self.buyLabel = buyLabel
            self.sellLabel = sellLabel
        }

        struct CurrencyRate: Identifiable {

            let id: UUID
            let currencyName: String
            let exchangeRateBuy: String
            var exchangeRateBuyIcon: Image
            let exchangeRateSell: String
            var exchangeRateSellIcon: Image
 
            internal init(id: UUID = UUID(), currencyName: String, exchangeRateBuy: String, buyingExchangeRateHasRisen: Bool, exchangeRateSell: String, sellingExchangeRateHasRisen: Bool) {
                
                self.id = id
                self.currencyName = currencyName
                self.exchangeRateBuy = exchangeRateBuy
                self.exchangeRateSell = exchangeRateSell
                self.exchangeRateBuyIcon = Image.ic16PoligonDown.foregroundColor(.systemColorError) as! Image
                self.exchangeRateSellIcon = Image.ic16PoligonDown.foregroundColor(.systemColorError) as! Image

                if buyingExchangeRateHasRisen {
                    self.exchangeRateBuyIcon = Image.ic16PoligonUp.foregroundColor(.systemColorActive) as! Image
                }

                if sellingExchangeRateHasRisen {
                    self.exchangeRateSellIcon = Image.ic16PoligonUp.foregroundColor(.systemColorActive) as! Image
                }
            }
        }
    }
}

//MARK: - View

struct CurrencyExchangeView: View {
    
    var viewModel: ViewModel
    
    var body: some View {

        VStack(spacing: 0) {
            
            HStack {
                
                Text(viewModel.currencyLabel)
                    .font(.textBodyMM14200())
                    .foregroundColor(.textPlaceholder)
                    .padding(.leading, 12)
                
                Spacer()
                
                Text(viewModel.buyLabel)
                    .font(.textBodyMM14200())
                    .foregroundColor(.textPlaceholder)
                    .padding(.trailing, 30)
                
                Text(viewModel.sellLabel)
                    .font(.textBodyMM14200())
                    .foregroundColor(.textPlaceholder)
                    .padding(.trailing, 12)
            }
            .padding(.top, 8)
            
            ForEach(viewModel.currencyRate) { item in
                
                CurrencyView(viewModel: item)
                    .padding(.top, 16)
            }
        }
        .padding(.bottom, 16)
        .background(Color.mainColorsGrayLightest)
        .cornerRadius(12)
        .padding(.horizontal, 20)
    }
    
    struct CurrencyView: View {
        
        let viewModel: ViewModel.CurrencyRate
        
        var body: some View {

            HStack {

                Text(viewModel.currencyName)
                    .font(.textH4M16240())
                    .foregroundColor(.textSecondary)
                    .padding(.leading, 12)
                
                Spacer()
                
                HStack(spacing: 0) {

                    viewModel.exchangeRateBuyIcon

                    Text(viewModel.exchangeRateBuy)
                        .foregroundColor(.textSecondary)
                        .font(.textH4M16240())
                }
                .padding(.trailing, 21)
        
                HStack(spacing: 0) {

                    viewModel.exchangeRateSellIcon

                    Text(viewModel.exchangeRateSell)
                        .foregroundColor(.textSecondary)
                        .font(.textH4M16240())
                }
                .padding(.trailing, 30)
            }
        }
    }
}

//MARK: - Preview

struct CurrencyExchangeView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            CurrencyExchangeView(viewModel: .sample)
        }
    }
}

//MARK: - Preview Content

extension CurrencyExchangeView.ViewModel {
    
    static let sample =  CurrencyExchangeView.ViewModel.init(currencyRate: [
        .init(currencyName: "Евро",
              exchangeRateBuy: "87,85",
              buyingExchangeRateHasRisen: true,
              exchangeRateSell: "87,85",
              sellingExchangeRateHasRisen: false),
        .init(currencyName: "Доллар США",
              exchangeRateBuy: "87,15",
              buyingExchangeRateHasRisen: false,
              exchangeRateSell: "87,15",
              sellingExchangeRateHasRisen: true)])
}
