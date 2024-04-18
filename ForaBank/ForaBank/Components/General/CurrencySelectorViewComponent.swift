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
        @Published var bottomSheet: BottomSheet?
        @Published var isUserInteractionEnabled: Bool
        @Published var productCardSelector: CurrencyWalletSelectorViewModel?
        @Published var productAccountSelector: CurrencyWalletSelectorViewModel?
        
        let model: Model
        let id = UUID().uuidString
        
        lazy var openAccount: CurrencyWalletAccountView.ViewModel = makeOpenAccount()
        private var bindings = Set<AnyCancellable>()
        
        init(_ model: Model, state: State, currency: Currency, currencyOperation: CurrencyOperation, isUserInteractionEnabled: Bool = true) {
            
            self.model = model
            self.state = state
            self.currency = currency
            self.currencyOperation = currencyOperation
            self.isUserInteractionEnabled = isUserInteractionEnabled
            
            productCardSelector = makeProductCardSelector()
            productAccountSelector = makeProductAccountSelector()
            
            bind()
        }
        
        enum State {
            
            case openAccount
            case productSelector
        }
        
        struct BottomSheet: BottomSheetCustomizable {
            
            let id = UUID()
            let type: SheetType
            
            enum SheetType {
                case openAccount(OpenAccountViewModel)
            }
        }
        
        private func bind() {
            
            model.action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                    case _ as ModelAction.Account.MakeOpenAccount.Request:
                        
                        productAccountSelector = makeProductAccountSelector()
                        updateProductSelectors(currencyOperation: currencyOperation)
                        
                        state = .productSelector
                        
                    case let payload as ModelAction.Account.MakeOpenAccount.Response:
                      
                        if case .failed = payload {
                            state = .openAccount
                        }
                     
                    default:
                        break
                    }
                    
                }.store(in: &bindings)
            
            model.products
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] productsData in
                    
                    makeProductViewModel(products: productsData)

                }.store(in: &bindings)
            
            openAccount.action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                    case _ as CurrencyWalletAccountView.ProductAction.Toggle:

                        let productsList = model.accountProductsList.value.filter { $0.currency.description == currency.description }
                        
                        guard let viewModel = OpenAccountViewModel(model, product: productsList.first, closeAction: { [weak self] in self?.bottomSheet = nil }) else {
                            return
                        }
                        
                        bottomSheet = .init(type: .openAccount(viewModel))

                    default:
                        break
                    }
                    
                }.store(in: &bindings)
            
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
                    
                    if let productCardSelector = productCardSelector,
                       let productAccountSelector = productAccountSelector  {
                        
                        productCardSelector.currencyOperation = currencyOperation
                        productAccountSelector.currencyOperation = currencyOperation
                    }
                    
                    updateProductSelectors(currencyOperation: currencyOperation)
                    
                }.store(in: &bindings)
            
            $isUserInteractionEnabled
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] isEnabled in
                    
                    productCardSelector?.isUserInteractionEnabled = isEnabled
                    productAccountSelector?.isUserInteractionEnabled = isEnabled
                    openAccount.isUserInteractionEnabled = isEnabled
                    
                }.store(in: &bindings)
        }
        
        private func makeProductCardSelector() -> CurrencyWalletSelectorViewModel? {
            
            let products = model.products(currency: .rub, currencyOperation: currencyOperation).sorted { $0.productType.order < $1.productType.order }
            
            guard let productData = products.first else {
                return nil
            }
            
            let selectorViewModel: CurrencyWalletSelectorViewModel = .init(model, currency: .rub, currencyOperation: currencyOperation, productViewModel: .init(productId: productData.id, productData: productData, model: model))
            
            return selectorViewModel
        }
        
        private func makeProductViewModel(products: ProductsData) {
            
            let products = model.products(products: products, currency: currency, currencyOperation: currencyOperation).sorted { $0.productType.order < $1.productType.order }
            
            guard let productData = products.first,
                  let productAccountSelector = productAccountSelector else {
                return
            }
            
            productAccountSelector.productViewModel = .init(productId: productData.id, productData: productData, model: model)
        }
        
        private func makeProductAccountSelector() -> CurrencyWalletSelectorViewModel? {
            
            let products = model.products(currency: currency, currencyOperation: currencyOperation).sorted { $0.productType.order < $1.productType.order }
            
            guard let productData = products.first else {
                
                let selectorViewModel: CurrencyWalletSelectorViewModel = .init(model, currency: currency, currencyOperation: currencyOperation, productViewModel: nil, isDividerHiddable: true)
                
                return selectorViewModel
            }
            
            let selectorViewModel: CurrencyWalletSelectorViewModel = .init(model, currency: currency, currencyOperation: currencyOperation, productViewModel: .init(productId: productData.id, productData: productData, model: model), isDividerHiddable: true)
            
            return selectorViewModel
        }
        
        private func updateProductSelectors(currencyOperation: CurrencyOperation) {
            
            if let productCardSelector = productCardSelector {
                
                withAnimation {
                    
                    let equalityOperation = currencyOperation == .buy
                    
                    productCardSelector.title = equalityOperation ? "Откуда" : "Куда"
                    productCardSelector.isDividerHiddable = equalityOperation ? false : true
                }
            }
            
            if let productAccountSelector = productAccountSelector {
                
                withAnimation {
                    
                    let equalityOperation = currencyOperation == .buy

                    productAccountSelector.title = equalityOperation ? "Куда" : "Откуда"
                    productAccountSelector.isDividerHiddable = equalityOperation ? true : false
                }
            }
            
            if state == .openAccount {
                
                withAnimation {
                    openAccount.title = currencyOperation == .buy ? "Куда" : "Откуда"
                }
            }
        }
        
        private func makeOpenAccount() -> CurrencyWalletAccountView.ViewModel {
            
            let title = currencyOperation == .buy ? "Куда" : "Откуда"
            
            if let currencyData = model.dictionaryCurrency(for: currency.description),
               let currencySymbol = currencyData.currencySymbol {
                return .init(model: model, title: title, currencySymbol: currencySymbol, currency: currency)
            }
            
            return .init(model: model, title: title, currency: currency)
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
                            CurrencyWalletSelectorView(viewModel: productCardSelector)
                                .matchedGeometryEffect(id: "currencySelector", in: namespace)
                        }
                        
                        switch viewModel.state {
                        case .openAccount:
                            
                            CurrencyWalletAccountView(viewModel: viewModel.openAccount)
                                .matchedGeometryEffect(id: "currencyAccount", in: namespace)
                            
                        case .productSelector:
                            
                            if let productAccountSelector = viewModel.productAccountSelector {
                                CurrencyWalletSelectorView(viewModel: productAccountSelector)
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
                                CurrencyWalletSelectorView(viewModel: productAccountSelector)
                                    .matchedGeometryEffect(id: "currencyProduct", in: namespace)
                            }
                        }
                        
                        if let productCardSelector = viewModel.productCardSelector {
                            CurrencyWalletSelectorView(viewModel: productCardSelector)
                                .matchedGeometryEffect(id: "currencySelector", in: namespace)
                        }
                    }
                    
                } else {
                    
                    if viewModel.currencyOperation == .buy {
                        
                        if let productCardSelector = viewModel.productCardSelector {
                            CurrencyWalletSelectorView(viewModel: productCardSelector)
                                .transition(bottomTransition)
                        }
                        
                        switch viewModel.state {
                        case .openAccount:
                            
                            CurrencyWalletAccountView(viewModel: viewModel.openAccount)
                                .transition(topTransition)
                            
                        case .productSelector:
                            
                            if let productAccountSelector = viewModel.productAccountSelector {
                                CurrencyWalletSelectorView(viewModel: productAccountSelector)
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
                                CurrencyWalletSelectorView(viewModel: productAccountSelector)
                                    .transition(bottomTransition)
                            }
                        }
                        
                        if let productCardSelector = viewModel.productCardSelector {
                            CurrencyWalletSelectorView(viewModel: productCardSelector)
                                .transition(topTransition)
                        }
                    }
                }
                
            }.padding(.vertical, 20)
        }
        .bottomSheet(item: $viewModel.bottomSheet) { bottomSheet in
            switch bottomSheet.type {
            case let .openAccount(viewModel):
                OpenAccountView(viewModel: viewModel)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, 20)
    }
}

// MARK: - Preview Content

extension CurrencySelectorView.ViewModel {
    
    static let sample: CurrencySelectorView.ViewModel = .init(
        .productsMock,
        state: .openAccount,
        currency: .rub,
        currencyOperation: .buy
    )
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

