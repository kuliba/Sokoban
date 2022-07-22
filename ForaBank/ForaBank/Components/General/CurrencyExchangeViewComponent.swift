//
//  CurrencyExchangeViewComponent.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 04.03.2022.
//

import SwiftUI
import Combine

//MARK: - ViewModel

extension CurrencyExchangeView {
    
    class ViewModel: ObservableObject {

        let header: HeaderViewModel
        @Published var rates: [CurrencyRateViewModel]
        
        private let model: Model
        private var bindings = Set<AnyCancellable>()
        
        private let displayCurrencies: [Currency] = [.eur, .usd]

        init(header: HeaderViewModel, rates: [CurrencyRateViewModel], model: Model = .emptyMock) {

            self.header = header
            self.rates = rates
            self.model = model
        }
        
        init(_ model: Model) {
            
            self.header = .init()
            self.rates = []
            self.model = model
            
            bind()
        }
        
        private func bind() {
            
            model.rates
                .receive(on: DispatchQueue.main)
                .sink {[unowned self] ratesData in
                    
                    var updated = [CurrencyRateViewModel]()
                    
                    for currency in displayCurrencies {
                        
                        guard let rate = ratesData.first(where: { $0.currency == currency }) else {
                            
                            continue
                        }
                        
                        let rateViewModel = CurrencyRateViewModel(with: rate)
                        updated.append(rateViewModel)
                    }
                    
                    withAnimation {
                        
                        rates = updated
                    }
          
                }.store(in: &bindings)
        }
    }
}

//MARK: - Types

extension CurrencyExchangeView.ViewModel {
    
    struct HeaderViewModel {
        
        var currency: String = "Валюта"
        var buy: String = "Купить"
        var sell: String = "Продать"
    }

    struct CurrencyRateViewModel: Identifiable {

        let id: Currency
        let title: String
        let buy: RateViewModel
        let sell: RateViewModel
        
        init(id: Currency, title: String, buy: RateViewModel, sell: RateViewModel) {
            
            self.id = id
            self.title = title
            self.buy = buy
            self.sell = sell
        }
        
        init(with rate: ExchangeRateData) {
            
            let formatter = NumberFormatter.currencyRate
            let buyValue = formatter.string(from: NSNumber(value: rate.rateSell)) ?? String(rate.rateSell)
            let sellValue = formatter.string(from: NSNumber(value: rate.rateBuy)) ?? String(rate.rateBuy)
            
            self.id = rate.currency
            self.title = rate.currencyName
            self.buy = RateViewModel(value: buyValue, icon: .ic16PoligonUp, iconColor: .clear)
            self.sell = RateViewModel(value: sellValue, icon: .ic16PoligonUp, iconColor: .clear)
        }
        
        struct RateViewModel {
            
            let value: String
            let icon: Image
            let iconColor: Color
        }
    }
}

//MARK: - View

struct CurrencyExchangeView: View {
    
    @ObservedObject var viewModel: ViewModel
    
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
                    
                    Text(viewModel.sell)
                        .font(.textBodyMM14200())
                        .foregroundColor(.textPlaceholder)
                        .frame(width: 70, alignment: .leading)
     
                    Text(viewModel.buy)
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

                Text(viewModel.title)
                    .font(.textH4M16240())
                    .foregroundColor(.textSecondary)
                
                Spacer()
                
                HStack(spacing: 25) {
                    
                    RateView(viewModel: viewModel.sell)
                        .frame(width: 70, alignment: .leading)
                    
                    RateView(viewModel: viewModel.buy)
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
    
    static let sample = CurrencyExchangeView.ViewModel(header: .init(), rates: [.init(id: .eur, title: "Евро", buy: .init(value: "87,15", icon: .ic16PoligonUp, iconColor: .systemColorActive), sell: .init(value: "94,85", icon: .ic16PoligonDown, iconColor: .systemColorError)), .init(id: .usd, title: "Доллар США", buy: .init(value: "87,15", icon: .ic16PoligonUp, iconColor: .systemColorActive), sell: .init(value: "94,85", icon: .ic16PoligonDown, iconColor: .systemColorError))])
    
}
