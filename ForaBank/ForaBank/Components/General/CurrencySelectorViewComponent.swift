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
                
                ProductSelectorView(viewModel: .sample1)
                
                switch viewModel.state {
                case .openAccount:
                    CurrencyWalletAccountView(viewModel: viewModel.openAccount)
                case .productSelector:
                    ProductSelectorView(viewModel: .sample3)
                }
                
            }.padding(.vertical, 20)
            
        }.padding(20)
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
            .frame(height: 300)
    }
}
