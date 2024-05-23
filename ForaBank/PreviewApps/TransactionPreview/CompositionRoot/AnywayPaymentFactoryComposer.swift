//
//  AnywayPaymentFactoryComposer.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 21.05.2024.
//

import AnywayPaymentDomain
import PaymentComponents
import RxViewModel
import SwiftUI

final class AnywayPaymentFactoryComposer {
    
    private let config: AnywayPaymentElementConfig
    private let currencyOfProduct: CurrencyOfProduct
    private let getProducts: GetProducts
    
    init(
        config: AnywayPaymentElementConfig,
        currencyOfProduct: @escaping CurrencyOfProduct,
        getProducts: @escaping GetProducts
    ) {
        self.config = config
        self.currencyOfProduct = currencyOfProduct
        self.getProducts = getProducts
    }
}

extension AnywayPaymentFactoryComposer {
    
    func compose(
        event: @escaping (AnywayPaymentEvent) -> Void
    ) -> Factory {
        
        let factory = AnywayPaymentElementViewFactory(
            makeIconView: makeIconView,
            makeProductSelectView: makeProductSelectView,
            elementFactory: makeElementFactory()
        )
        
        return .init(
            makeElementView: { 
                
                return .init(
                    state: $0, 
                    event: event,
                    factory: factory,
                    config: self.config
                )
            },
            makeFooterView: { .init() }
        )
    }
}

extension AnywayPaymentFactoryComposer {
    
    typealias CurrencyOfProduct = (ProductSelect.Product) -> String
    typealias GetProducts = () -> [ProductSelect.Product]
    typealias Factory = AnywayPaymentFactory<IconView>
    
    #warning("FIXME: should be some image view/some view")
    typealias IconView = Text
}

private extension AnywayPaymentFactoryComposer {
    
    func makeIconView(
        component: UIComponent
    ) -> IconView {
        
        #warning("FIXME")
        return .init("?")
    }
    
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
    
    func makeElementFactory(
    ) -> AnywayPaymentParameterViewFactory {
        
        return .init(
            makeSelectorView: makeSelectorView,
            makeTextInputView: makeTextInputView
        )
    }
    
    func makeSelectorView(
        selector: Selector<Option>,
        observe: @escaping (Selector<Option>) -> Void
    ) -> SelectorWrapperView {
        
        let reducer = SelectorReducer<Option>()
        let viewModel = RxViewModel(
            initialState: selector,
            reduce: reducer.reduce(_:_:),
            handleEffect: { _,_ in }
        )
        
        let observing = RxObservingViewModel(
            observable: viewModel,
            observe: observe
        )
        
        return .init(
            viewModel: observing,
            factory: .init(
                createOptionView: OptionView.init,
                createSelectedOptionView: SelectedOptionView.init
            )
        )
    }
    
    func makeTextInputView(
        parameter: UIComponent.Parameter,
        observe: @escaping (InputState<String>) -> Void
    ) -> InputStateWrapperView {
        
        let inputState = InputState(parameter)
        let reducer = InputReducer<String>()
        let viewModel = RxViewModel(
            initialState: inputState,
            reduce: reducer.reduce(_:_:),
            handleEffect: { _,_ in }
        )
        
        let observing = RxObservingViewModel(
            observable: viewModel,
            observe: observe
        )
        
        return .init(
            viewModel: observing,
            factory: .init(makeIconView: {
                
                #warning("FIXME")                
                
                return .init()
            })
        )
    }
    
    typealias UIComponent = AnywayPayment.Element.UIComponent
    typealias Option = UIComponent.Parameter.ParameterType.Option

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

// MARK: - Adapters

private extension InputState where Icon == String {
    
    #warning("FIXME: replace stubbed with values from parameter")
    init(_ parameter: AnywayPayment.Element.UIComponent.Parameter) {
        
        self.init(
            dynamic: .init(
                value: parameter.value?.rawValue ?? "",
                warning: nil
            ),
            settings: .init(
                hint: nil,
                icon: "",
                keyboard: .default,
                title: parameter.title,
                subtitle: parameter.subtitle
            )
        )
    }
}
