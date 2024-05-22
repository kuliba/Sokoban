//
//  AnywayPaymentFactoryComposer.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 21.05.2024.
//

import AnywayPaymentDomain
import PaymentComponents

final class AnywayPaymentFactoryComposer {
    
    private let currencyOfProduct: CurrencyOfProduct
    private let getProducts: GetProducts
    
    init(
        currencyOfProduct: @escaping CurrencyOfProduct,
        getProducts: @escaping GetProducts
    ) {
        self.currencyOfProduct = currencyOfProduct
        self.getProducts = getProducts
    }
}

extension AnywayPaymentFactoryComposer {
    
    func compose(
        event: @escaping (AnywayPaymentEvent) -> Void
    ) -> Factory {
        
        let factory = AnywayPaymentElementViewFactory(
            widget: .init(makeProductSelectView: makeProductSelectView)
        )
        
        return .init(
            makeElementView: { .init(state: $0, event: event, factory: factory) },
            makeFooterView: { .init() }
        )
    }
}

extension AnywayPaymentFactoryComposer {
    
    typealias CurrencyOfProduct = (ProductSelect.Product) -> String
    typealias GetProducts = () -> [ProductSelect.Product]
    typealias Factory = AnywayPaymentFactory
}

private extension AnywayPaymentFactoryComposer {
    
    func makeProductSelectView(
        productID: ProductID,
        observe: @escaping Observe
    ) -> ProductSelectStateWrapperView {
        
        let products = getProducts()
        let selected = products.first { $0.isMatching(productID) }
        let initialState = ProductSelect(selected: selected)
        
        let reducer = ProductSelectReducer(getProducts: getProducts)
        
        let observable = ProductSelectViewModel(
            initialState: initialState,
            reduce: { (reducer.reduce($0, $1), nil) },
            handleEffect: { _,_ in }
        )
        let observing = ObservingProductSelectViewModel(
            observable: observable,
            observe: { [weak self] in
                
                guard let self else { return }
                
                guard let productID = $0.selected?.coreProductID,
                      let currency = $0.selected.map({ self.currencyOfProduct($0) })
                else { return }
                
                observe(productID, .init(currency))
            }
        )
        
        return .init(viewModel: observing, config: .iFora)
    }
    
    typealias Observe = (ProductID, Currency) -> Void
    typealias ProductID = AnywayPayment.Element.Widget.PaymentCore.ProductID
    typealias Currency = AnywayPaymentEvent.Widget.Currency
}

private extension ProductSelect.Product {
    
    func isMatching(
        _ productID: AnywayPayment.Element.Widget.PaymentCore.ProductID
    ) -> Bool {
        
        switch productID {
        case let .accountID(accountID):
            return type == .account && id.rawValue == accountID.rawValue
            
        case let .cardID(cardID):
            return type == .card && id.rawValue == cardID.rawValue
        }
    }
    
    var coreProductID: AnywayPayment.Element.Widget.PaymentCore.ProductID {
        
        switch type {
        case .account:
            return .accountID(.init(id.rawValue))
            
        case .card:
            return .cardID(.init(id.rawValue))
        }
    }
}
