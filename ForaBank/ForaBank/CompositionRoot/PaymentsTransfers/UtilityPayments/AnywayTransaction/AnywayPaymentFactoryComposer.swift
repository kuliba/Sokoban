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
            parameterFactory: makeElementFactory()
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
    typealias MakeIconView = (String) -> IconView
    
    typealias Factory = AnywayPaymentFactory<IconView>
}

private extension AnywayPaymentFactoryComposer {
    
    func makeElementFactory(
    ) -> AnywayPaymentParameterViewFactory {
        
        return .init(
            makeSelectorView: makeSelectorView,
            makeIconView: makeIconView
        )
    }
    
    func makeSelectorView(
        viewModel: ObservingSelectorViewModel<Option>
    ) -> SelectorWrapperView {
        
        return .init(
            viewModel: viewModel,
            factory: .init(
                createOptionView: OptionView.init,
                createSelectedOptionView: SelectedOptionView.init
            )
        )
    }
        
    typealias Option = UIComponent.Parameter.ParameterType.Option

    typealias Observe = (ProductID, Currency) -> Void
    typealias ProductID = AnywayElement.Widget.PaymentCore.ProductID
    typealias Currency = AnywayPaymentEvent.Widget.Currency
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
