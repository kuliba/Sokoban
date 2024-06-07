//
//  AnywayPaymentFactoryComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.05.2024.
//

import AnywayPaymentCore
import AnywayPaymentDomain
import PaymentComponents
import RxViewModel
import SwiftUI
import UIPrimitives

final class AnywayPaymentFactoryComposer {
    
    private let config: AnywayPaymentElementConfig
    private let currencyOfProduct: CurrencyOfProduct
    private let getProducts: GetProducts
    private let makeIconView: MakeIconView
    
    init(
        config: AnywayPaymentElementConfig,
        currencyOfProduct: @escaping CurrencyOfProduct,
        getProducts: @escaping GetProducts,
        makeIconView: @escaping MakeIconView
    ) {
        self.config = config
        self.currencyOfProduct = currencyOfProduct
        self.getProducts = getProducts
        self.makeIconView = makeIconView
    }
}

extension AnywayPaymentFactoryComposer {
    
    func compose(
        event: @escaping (AnywayPaymentEvent) -> Void
    ) -> Factory {
        
        let elementFactory = AnywayPaymentElementViewFactory(
            makeIconView: makeIconView,
            elementFactory: makeElementFactory()
        )
        
        return .init(
            makeElementView: {
                
                return .init(
                    state: $0,
                    event: event,
                    factory: elementFactory,
                    config: self.config
                )
            },
            makeFooterView: { state, event in
                
                return .init(state: state.footer, event: event, config: .iFora)
            }
        )
    }
}

extension AnywayPaymentFactoryComposer {
    
    typealias CurrencyOfProduct = (ProductSelect.Product) -> String
    typealias GetProducts = () -> [ProductSelect.Product]

    typealias UIComponent = AnywayPaymentDomain.AnywayElement.UIComponent
    typealias IconView = UIPrimitives.AsyncImage
    typealias MakeIconView = (UIComponent) -> IconView
    
    typealias Factory = AnywayPaymentFactory<IconView>
}

private extension AnywayPaymentFactoryComposer {
    
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
    
    typealias Option = UIComponent.Parameter.ParameterType.Option

    typealias Observe = (ProductID, Currency) -> Void
    typealias ProductID = AnywayElement.Widget.PaymentCore.ProductID
    typealias Currency = AnywayPaymentEvent.Widget.Currency
}


// MARK: - Adapters

private extension InputState where Icon == String {
    
    #warning("FIXME: replace stubbed with values from parameter")
    init(_ parameter: AnywayPaymentDomain.AnywayElement.UIComponent.Parameter) {
        
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

private extension CachedTransactionState {
    
    var footer: AnywayPaymentFooter {
        
        #warning("FIXME: buttonTitle")
        return .init(buttonTitle: "Continue", core: core, isEnabled: isValid)
    }
    
    var core: AnywayPaymentFooter.Core? {
        
        context.payment.models.core
    }
}

private extension Array where Element == CachedAnywayPayment<AnywayElementModel>.IdentifiedModel {
    
    var core: AnywayPaymentFooter.Core? {
        
        guard case let .widget(.core(core, amount, currency)) = self[id: .widgetID(.core)]?.model
        else { return nil }
        
        return .init(value: amount, currency: currency)
    }
}
