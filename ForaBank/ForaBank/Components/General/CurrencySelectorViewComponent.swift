//
//  CurrencySelectorViewComponent.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 17.07.2022.
//

import SwiftUI
import Combine

// MARK: - ViewModel

extension CurrencySelectorView {
    
    class ViewModel: ObservableObject, CurrencyWalletItem {
        
        @Published var state: State
        @Published var currency: Currency
        @Published var currencyOperation: CurrencyOperation
        
        let model: Model
        let id = UUID().uuidString
        
        private var bindings = Set<AnyCancellable>()
        
        lazy var productCardSelector: ProductSelectorViewModel? = makeProductCardSelector()
        lazy var productAccountSelector: ProductSelectorViewModel? = makeProductAccountSelector()
        lazy var openAccount: CurrencyWalletAccountView.ViewModel = makeOpenAccount()
        
        init(_ model: Model, state: State, currency: Currency, currencyOperation: CurrencyOperation) {
            
            self.model = model
            self.state = state
            self.currency = currency
            self.currencyOperation = currencyOperation
            
            bind()
        }
        
        enum State {
            
            case openAccount
            case productSelector
        }
        
        private func bind() {
            
            $currency
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] currency in
                    
                    if state == .openAccount {
                        openAccount.currency = currency
                    }
                    
                    guard let productAccountSelector = productAccountSelector else {
                        return
                    }
                    
                    productAccountSelector.currency = currency
                    
                }.store(in: &bindings)
            
            $currencyOperation
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] currencyOperation in
                    
                    updateProductSelectors(currencyOperation: currencyOperation)
                    
                }.store(in: &bindings)
        }
        
        private func makeProductCardSelector() -> ProductSelectorView.ViewModel? {
            
            let products = model.products(currency: .rub).sorted { $0.productType.order < $1.productType.order }
            
            guard let productData = products.first else {
                return nil
            }
            
            let selectorViewModel: ProductSelectorView.ViewModel = .init(model, currency: .rub, productViewModel: .init(productId: productData.id, productData: productData, model: model))
            
            return selectorViewModel
        }
        
        private func makeProductAccountSelector() -> ProductSelectorView.ViewModel? {
            
            let products = model.products(currency: currency).sorted { $0.productType.order < $1.productType.order }
            
            guard let productData = products.first else {
                return nil
            }
            
            let selectorViewModel: ProductSelectorView.ViewModel = .init(model, currency: currency, productViewModel: .init(productId: productData.id, productData: productData, model: model), isDividerHiddable: true)
            
            return selectorViewModel
        }
        
        private func updateProductSelectors(currencyOperation: CurrencyOperation) {
            
            if let productCardSelector = productCardSelector {
                
                withAnimation {
                    
                    let equalityOperation = currencyOperation == .buy
                    
                    productCardSelector.title = equalityOperation ? "Откуда" : "Куда"
                    productCardSelector.isDividerHiddable = equalityOperation ? false : true
                    productCardSelector.dividerViewModel.pathInset = equalityOperation ? 5 : -5
                }
            }
            
            if let productAccountSelector = productAccountSelector {
                
                withAnimation {
                    
                    let equalityOperation = currencyOperation == .buy

                    productAccountSelector.title = equalityOperation ? "Куда" : "Откуда"
                    productAccountSelector.isDividerHiddable = equalityOperation ? true : false
                    productAccountSelector.dividerViewModel.pathInset = equalityOperation ? 5 : -5
                }
            }
        }
        
        private func makeOpenAccount() -> CurrencyWalletAccountView.ViewModel {
            return .init(model: model, currency: currency)
        }
    }
}

// MARK: - View

struct CurrencySelectorView: View {
    
    @Namespace private var namespace
    @ObservedObject var viewModel: ViewModel
    
    var topTransition: AnyTransition {
        .asymmetric(insertion: .move(edge: .top), removal: .identity)
    }

    var bottomTransition: AnyTransition {
        .asymmetric(insertion: .move(edge: .bottom), removal: .identity)
    }
    
    var body: some View {
        
        ZStack {
            
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(.mainColorsGrayLightest)
            
            VStack(spacing: 20) {
                
                if #available(iOS 14.0, *) {
                    
                    if viewModel.currencyOperation == .buy {
                        
                        if let productCardSelector = viewModel.productCardSelector {
                            ProductSelectorView(viewModel: productCardSelector)
                                .matchedGeometryEffect(id: "currencySelector", in: namespace)
                        }
                        
                        switch viewModel.state {
                        case .openAccount:
                            
                            CurrencyWalletAccountView(viewModel: viewModel.openAccount)
                                .matchedGeometryEffect(id: "currencyAccount", in: namespace)
                            
                        case .productSelector:
                            
                            if let productAccountSelector = viewModel.productAccountSelector {
                                ProductSelectorView(viewModel: productAccountSelector)
                                    .matchedGeometryEffect(id: "currencyProduct", in: namespace)
                            }
                        }
                        
                    } else {
                        
                        switch viewModel.state {
                        case .openAccount:
                            
                            CurrencyWalletAccountView(viewModel: viewModel.openAccount)
                                .matchedGeometryEffect(id: "currencyAccount", in: namespace)
                            
                        case .productSelector:
                            
                            if let productAccountSelector = viewModel.productAccountSelector {
                                ProductSelectorView(viewModel: productAccountSelector)
                                    .matchedGeometryEffect(id: "currencyProduct", in: namespace)
                            }
                        }
                        
                        if let productCardSelector = viewModel.productCardSelector {
                            ProductSelectorView(viewModel: productCardSelector)
                                .matchedGeometryEffect(id: "currencySelector", in: namespace)
                        }
                    }
                    
                } else {
                    
                    if viewModel.currencyOperation == .buy {
                        
                        if let productCardSelector = viewModel.productCardSelector {
                            ProductSelectorView(viewModel: productCardSelector)
                                .transition(bottomTransition)
                        }
                        
                        switch viewModel.state {
                        case .openAccount:
                            
                            CurrencyWalletAccountView(viewModel: viewModel.openAccount)
                                .transition(topTransition)
                            
                        case .productSelector:
                            
                            if let productAccountSelector = viewModel.productAccountSelector {
                                ProductSelectorView(viewModel: productAccountSelector)
                                    .transition(topTransition)
                            }
                        }
                        
                    } else {
                        
                        switch viewModel.state {
                        case .openAccount:
                            
                            CurrencyWalletAccountView(viewModel: viewModel.openAccount)
                                .transition(bottomTransition)
                            
                        case .productSelector:
                            
                            if let productAccountSelector = viewModel.productAccountSelector {
                                ProductSelectorView(viewModel: productAccountSelector)
                                    .transition(bottomTransition)
                            }
                        }
                        
                        if let productCardSelector = viewModel.productCardSelector {
                            ProductSelectorView(viewModel: productCardSelector)
                                .transition(topTransition)
                        }
                    }
                }
                
            }.padding(.vertical, 20)
            
        }.padding(.horizontal, 20)
    }
}

// MARK: - Preview Content

extension CurrencySelectorView.ViewModel {
    
    static let sample: CurrencySelectorView.ViewModel = .init(.productsMock, state: .openAccount, currency: .rub, currencyOperation: .buy)
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
