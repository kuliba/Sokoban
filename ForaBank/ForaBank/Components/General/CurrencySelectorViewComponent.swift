//
//  CurrencySelectorViewComponent.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 17.07.2022.
//

import SwiftUI

// MARK: - ViewModel

extension CurrencySelectorView {
    
    class ViewModel: ObservableObject, CurrencyWalletItem {
        
        @Published var state: State
        
        let model: Model
        var id = UUID().uuidString
        
        lazy var productCardSelector: ProductSelectorViewModel? = makeProductCardSelector()
        lazy var productAccountSelector: ProductSelectorViewModel? = makeProductAccountSelector()
        
        lazy var openAccount: CurrencyWalletAccountView.ViewModel = .init(
            model: model,
            cardIcon: Image("USD Account"),
            currency: Currency(description: "USD"),
            currencyName: "Валютный",
            warning: .init(description: "Для завершения операции Вам необходимо открыть счет в долларах США"))
        
        init(_ model: Model, state: State) {
            
            self.model = model
            self.state = state
        }
        
        enum State {
            
            case openAccount
            case productSelector
        }
        
        private func makeProductCardSelector() -> ProductSelectorView.ViewModel? {
            
            guard let productCards = model.products.value[.card],
                  let productCard = productCards.first as? ProductCardData,
                  let numberCard = productCard.number else {
                return nil
            }
            
            let selectorViewModel: ProductSelectorView.ViewModel = .init(
                model,
                title: "Откуда",
                cardIcon: productCard.smallDesign.image,
                paymentSystemIcon: productCard.paymentSystemImage?.image,
                name: productCard.displayName,
                balance: NumberFormatter.decimal(productCard.balanceValue),
                number: .init(
                    numberCard: numberCard,
                    description: productCard.additionalField),
                productType: .card)
            
            return selectorViewModel
        }
        
        private func makeProductAccountSelector() -> ProductSelectorView.ViewModel? {
            
            guard let productCards = model.products.value[.account],
                  let productCard = productCards.first as? ProductAccountData,
                  let numberCard = productCard.number else {
                return nil
            }
            
            let selectorViewModel: ProductSelectorView.ViewModel = .init(
                model,
                title: "Куда",
                cardIcon: productCard.smallDesign.image,
                paymentSystemIcon: nil,
                name: productCard.displayName,
                balance: NumberFormatter.decimal(productCard.balanceValue),
                number: .init(
                    numberCard: numberCard,
                    description: productCard.additionalField),
                productType: .account,
                isDividerHiddable: true)
            
            return selectorViewModel
        }
    }
}

// MARK: - View

struct CurrencySelectorView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        ZStack {
            
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(.mainColorsGrayLightest)
            
            VStack(spacing: 20) {
                
                if let productCardSelector = viewModel.productCardSelector {
                    ProductSelectorView(viewModel: productCardSelector)
                }
                
                switch viewModel.state {
                case .openAccount:
                    
                    CurrencyWalletAccountView(viewModel: viewModel.openAccount)
                    
                case .productSelector:
                    
                    if let productAccountSelector = viewModel.productAccountSelector {
                        ProductSelectorView(viewModel: productAccountSelector)
                    }
                }
                
            }.padding(.vertical, 20)
            
        }.padding(.horizontal, 20)
    }
}

// MARK: - Preview Content

extension CurrencySelectorView.ViewModel {
    
    static let sample: CurrencySelectorView.ViewModel = .init(.productsMock, state: .openAccount)
}

// MARK: - Previews

struct CurrencySelectorViewComponent_Previews: PreviewProvider {
    static var previews: some View {
        CurrencySelectorView(viewModel: .sample)
            .previewLayout(.sizeThatFits)
            .frame(height: 200)
            .padding(.vertical)
    }
}
