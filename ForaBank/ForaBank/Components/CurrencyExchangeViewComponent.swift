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

        let header: HeaderViewModel
        let rates: [CurrencyRateViewModel]

        internal init(header: HeaderViewModel, rates: [CurrencyRateViewModel]) {

            self.header = header
            self.rates = rates
        }
        
        struct HeaderViewModel {
            
            var currency: String = "Валюта"
            var buy: String = "Купить"
            var sell: String = "Продать"
        }

        struct CurrencyRateViewModel: Identifiable {
 
            let id: UUID
            let currency: String
            let buy: RateViewModel
            let sell: RateViewModel
            
            internal init(id: UUID = UUID(), currency: String, buy: RateViewModel, sell: RateViewModel) {
                
                self.id = id
                self.currency = currency
                self.buy = buy
                self.sell = sell
            }
            
            /*
 
            internal init(id: UUID = UUID(), currencyName: String, exchangeRateBuy: String, buyingExchangeRateHasRisen: Bool, exchangeRateSell: String, sellingExchangeRateHasRisen: Bool) {
                
                self.id = id
                self.currency = currencyName
                self.exchangeRateBuy = exchangeRateBuy
                self.exchangeRateSell = exchangeRateSell
                self.exchangeRateBuyIcon = Image.ic16PoligonDown
                self.exchangeRateSellIcon = Image.ic16PoligonDown

                if buyingExchangeRateHasRisen {
                    self.exchangeRateBuyIcon = Image.ic16PoligonUp
                }

                if sellingExchangeRateHasRisen {
                    self.exchangeRateSellIcon = Image.ic16PoligonUp
                }
            }
             */
            
            struct RateViewModel {
                
                let value: String
                let icon: Image
                let iconColor: Color
            }
        }
    }
}

//MARK: - View

struct CurrencyExchangeView: View {
    
    var viewModel: ViewModel
    
    var body: some View {

        VStack(spacing: 16) {
            
            HeaderView(viewModel: viewModel.header)
            
            ForEach(viewModel.rates) { currencyRateViewModel in
                
                CurrencyView(viewModel: currencyRateViewModel)
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 16)
        .padding(.horizontal, 12)
        .background(Color.mainColorsGrayLightest)
        .cornerRadius(12)
        .padding(.horizontal, 20)
    }
    
    struct HeaderView: View {
        
        let viewModel: ViewModel.HeaderViewModel
        
        var body: some View {
            
            HStack {
                
                Text(viewModel.currency)
                    .font(.textBodyMM14200())
                    .foregroundColor(.textPlaceholder)
                
                Spacer()
                
                HStack(spacing: 25) {
                    
                    Text(viewModel.buy)
                        .font(.textBodyMM14200())
                        .foregroundColor(.textPlaceholder)
                        .frame(width: 70, alignment: .leading)
     
                    Text(viewModel.sell)
                        .font(.textBodyMM14200())
                        .foregroundColor(.textPlaceholder)
                        .frame(width: 70, alignment: .leading)
                }
            }
        }
    }
    
    struct CurrencyView: View {
        
        let viewModel: ViewModel.CurrencyRateViewModel
        
        var body: some View {

            HStack {

                Text(viewModel.currency)
                    .font(.textH4M16240())
                    .foregroundColor(.textSecondary)
                
                Spacer()
                
                HStack(spacing: 25) {
                    
                    RateView(viewModel: viewModel.buy)
                        .frame(width: 70, alignment: .leading)
                    
                    RateView(viewModel: viewModel.sell)
                        .frame(width: 70, alignment: .leading)
                        
                }.padding(.trailing, 16)
            }
        }
    }
    
    struct RateView: View {
        
        let viewModel: CurrencyExchangeView.ViewModel.CurrencyRateViewModel.RateViewModel
        
        var body: some View {
            
            HStack(spacing: 0) {

                viewModel.icon
                    .renderingMode(.template)
                    .foregroundColor(viewModel.iconColor)

                Text(viewModel.value)
                    .foregroundColor(.textSecondary)
                    .font(.textH4M16240())
            }
        }
    }
}

//MARK: - Preview

struct CurrencyExchangeView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            CurrencyExchangeView(viewModel: .sample)
                .previewLayout(.fixed(width: 375, height: 200))
        }
    }
}

//MARK: - Preview Content

extension CurrencyExchangeView.ViewModel {
    
    static let sample = CurrencyExchangeView.ViewModel(header: .init(), rates: [.init(currency: "Евро", buy: .init(value: "87,15", icon: .ic16PoligonUp, iconColor: .systemColorActive), sell: .init(value: "94,85", icon: .ic16PoligonDown, iconColor: .systemColorError)), .init(currency: "Доллар США", buy: .init(value: "87,15", icon: .ic16PoligonUp, iconColor: .systemColorActive), sell: .init(value: "94,85", icon: .ic16PoligonDown, iconColor: .systemColorError))])
    
}
