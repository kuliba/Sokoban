//
//  AnywayPaymentFactoryComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.05.2024.
//

import AnywayPaymentCore
import AnywayPaymentDomain
import OTPInputComponent
import PaymentComponents
import RxViewModel
import SwiftUI
import UIPrimitives

final class AnywayPaymentFactoryComposer {
    
    private let currencyOfProduct: CurrencyOfProduct
    private let makeIconView: MakeIconView
    
    init(
        currencyOfProduct: @escaping CurrencyOfProduct,
        makeIconView: @escaping MakeIconView
    ) {
        self.currencyOfProduct = currencyOfProduct
        self.makeIconView = makeIconView
    }
}

extension AnywayPaymentFactoryComposer {
    
    func compose(
        event: @escaping (AnywayPaymentEvent) -> Void
    ) -> Factory {
        
        let elementFactory = AnywayPaymentElementViewFactory(
            makeIconView: makeIconView,
            parameterFactory: makeElementFactory(), 
            widgetFactory: makeWidgetFactory()
        )
        
        return .init(
            makeElementView: { state in
                
                return .init(
                    state: state,
                    event: event,
                    factory: elementFactory,
                    config: .iFora
                )
            },
            makeFooterView: { footer in
                
                return .init(viewModel: footer, config: .iFora)
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
            makeSelectView: makeSelectView,
            makeSelectorView: makeSelectorView,
            makeIconView: makeIconView
        )
    }
    
    func makeSelectView(
        viewModel: ObservingSelectViewModel
    ) -> SelectWrapperView {
        
        return .init(viewModel: viewModel)
    }
    
    func makeSelectorView(
        viewModel: ObservingSelectorViewModel
    ) -> SelectorWrapperView {
        
        let image = viewModel.state.image
        let title = viewModel.state.title
        
        return .init(
            viewModel: viewModel,
            factory: .init(
                makeIconView: { self.makeIconView(image) },
                makeOptionLabel: {
                    
                    SimpleLabel(
                        text: $0.value, 
                        makeIconView: { Image.ic24RadioDefolt }
                    )
                },
                makeSelectedOptionLabel: SelectedOptionView.init,
                makeToggleLabel: { .init(state: $0, config: .iFora) }
            ),
            config: .iFora(title: title)
        )
    }
    
    private func makeIconView(
        _  image: AnywayElement.UIComponent.Image?
    ) -> IconView {
        
        switch image {
        case let .md5Hash(md5Hash):
            return makeIconView(md5Hash)
            
        default:
            return makeIconView("placeholder")
        }
    }
    
    typealias Option = UIComponent.Parameter.ParameterType.Option
    
    typealias Observe = (ProductID, Currency) -> Void
    typealias ProductID = AnywayElement.Widget.Product.ProductID
    typealias Currency = AnywayPaymentEvent.Widget.Currency
}

private extension AnywayPaymentFactoryComposer {
    
    func makeWidgetFactory(
    ) -> AnywayPaymentWidgetViewFactory {
        
        return .init(makeOTPView: makeOTPView)
    }
    
    private func makeOTPView(
        viewModel: TimedOTPInputViewModel
    ) -> AnywayPaymentWidgetViewFactory.OTPView {
        
        return .init(
            viewModel: viewModel, 
            config: .iFora,
            iconView: { self.makeIconView("sms") }
        )
    }
}

private extension AnywayTransactionState {
    
    var footer: AnywayPaymentFooter {
        
#warning("FIXME: hardcoded buttonTitle")
        return .init(buttonTitle: "Continue", core: core, isEnabled: transaction.isValid)
    }
    
    var core: AnywayPaymentFooter.Core? {
        
        let digest = transaction.context.makeDigest()
        
        let amount = digest.amount
        let currency = digest.core?.currency
        guard let amount, let currency else { return nil }
        
        return .init(value: amount, currency: currency)
    }
}
