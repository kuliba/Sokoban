//
//  CloseAccountViewComponent.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 31.08.2022.
//

import SwiftUI
import Combine

// MARK: - ViewModel

extension CloseAccountView {
    
    class ViewModel: ObservableObject {
        
        @Published var productFromSelector: ProductSelectorViewModel
        @Published var productToSelector: ProductSelectorViewModel
        
        let paymentsAmount: PaymentsAmountView.ViewModel
        let title = "Между своими"
        
        private let model: Model
        
        init(_ model: Model, productFrom: ProductData, productTo: ProductData) {
            
            self.model = model
            
            productFromSelector = Self.makeProductFromSelector(model, product: productFrom)
            productToSelector = Self.makeProductToSelector(model, product: productTo)
            paymentsAmount = Self.makePaymentsAmountViewModel(model, amount: productFrom.balanceValue)
        }
        
        init(_ model: Model, productFrom: ProductSelectorViewModel, productTo: ProductSelectorViewModel) {
            
            self.model = model
            self.productFromSelector = productFrom
            self.productToSelector = productTo
            
            paymentsAmount = Self.makePaymentsAmountViewModel(model, amount: 100)
        }
    }
}

extension CloseAccountView.ViewModel {
    
    private static func makeProductFromSelector(_ model: Model, product: ProductData) -> ProductSelectorViewModel {
        .init(model, product: product, backgroundColor: .gray)
    }
    
    private static func makeProductToSelector(_ model: Model, product: ProductData) -> ProductSelectorViewModel {
        
        let currency: Currency = .init(description: product.currency)
        
        let productContentViewModel: ProductContentViewModel = .init(
            productId: product.id,
            productData: product,
            model: model)
        
        let productSelector: ProductSelectorViewModel = .init(
            model,
            currency: currency,
            currencyOperation: .sell,
            productViewModel: productContentViewModel,
            isDividerHiddable: true)
        
        return productSelector
    }
    
    private static func makePaymentsAmountViewModel(_ model: Model, amount: Double) -> PaymentsAmountView.ViewModel {
        
        .init(title: "Сумма перевода",
              amount: amount,
              transferButton: .active(title: "Перевести") {})
    }
}

// MARK: - Action

extension CloseAccountView.ViewModel {
        
    enum CloseAccountAction {
        
        enum Button {
            
            struct Transfer: Action {}
        }
    }
}

// MARK: - View

struct CloseAccountView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        ZStack {
            
            VStack(alignment: .leading, spacing: 20) {
                
                Text(viewModel.title)
                    .font(.textH3SB18240())
                    .foregroundColor(.mainColorsBlack)
                    .padding(.horizontal, 20)
                
                ProductSelectorView(viewModel: viewModel.productFromSelector)
                ProductSelectorView(viewModel: viewModel.productToSelector)
                PaymentsAmountView(viewModel: viewModel.paymentsAmount)
                    .padding(.top, 32)
                
            }.padding(.top, 20)
            
        }.fixedSize(horizontal: false, vertical: true)
    }
}

struct CloseAccountView_Previews: PreviewProvider {
    static var previews: some View {
        CloseAccountView(viewModel: .init(.productsMock, productFrom: .sample1, productTo: .sample3))
            .background(Color.mainColorsGrayLightest)
            .previewLayout(.sizeThatFits)
    }
}
