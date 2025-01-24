//
//  AnywayPaymentFactoryComposer.swift
//  Vortex
//
//  Created by Igor Malyarov on 23.05.2024.
//

import AnywayPaymentCore
import AnywayPaymentDomain
import Combine
import VortexTools
import OTPInputComponent
import PaymentComponents
import RxViewModel
import SwiftUI
import UIPrimitives

final class AnywayPaymentFactoryComposer {
    
    private let currencyOfProduct: CurrencyOfProduct
    private let makeContactsView: MakeContactsView
    private let makeIconView: MakeIconView
    
    init(
        currencyOfProduct: @escaping CurrencyOfProduct,
        makeContactsView: @escaping MakeContactsView,
        makeIconView: @escaping MakeIconView
    ) {
        self.currencyOfProduct = currencyOfProduct
        self.makeContactsView = makeContactsView
        self.makeIconView = makeIconView
    }
}

extension AnywayPaymentFactoryComposer {
    
    func compose(
        event: @escaping (AnywayPaymentEvent) -> Void
    ) -> Factory {
        
        let elementFactory = AnywayPaymentElementViewFactory(
            makeContactsView: makeContactsView,
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
                    config: .iVortex
                )
            },
            makeFooterView: { footer in
                
                return .init(viewModel: footer, config: .iVortex)
            }
        )
    }
}

extension AnywayPaymentFactoryComposer {
    
    typealias CurrencyOfProduct = (ProductSelect.Product) -> String
    
    typealias UIComponent = AnywayPaymentDomain.AnywayElement.UIComponent
    typealias IconView = UIPrimitives.AsyncImage
    typealias MakeIconView = (UIComponent.Icon?) -> IconView
    
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
        parameter: AnywayElementModel.Parameter,
        viewModel: ObservingSelectorViewModel
    ) -> SelectorWrapperView {
        
        let icon = parameter.origin.icon
        let title = parameter.origin.title
        
        return .init(
            viewModel: viewModel,
            factory: .init(
                makeIconView: { self.makeIconView(icon) },
                makeItemLabel: { item in
                    
                    let isSelected = item == viewModel.state.selected
                    let image = isSelected ? Image.ic24RadioChecked : .ic24RadioDefolt
                    let iconColor: Color = isSelected ? .buttonPrimary : .buttonSecondaryHover
                    
                    return SimpleLabel(
                        text: item.value,
                        makeIconView: { image },
                        iconColor: iconColor
                    )
                },
                makeSelectedItemLabel: SelectedOptionView.init,
                makeToggleLabel: { .init(state: $0, config: .iVortex) }
            ),
            config: .iVortex(title: title)
        )
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
            config: .iVortex,
            iconView: { self.makeIconView(.md5Hash("sms")) },
            warningView: {
                
                OTPWarningView(text: viewModel.state.warning, config: .iVortex)
            }
        )
    }
}

private extension OTPInputState {
    
    var warning: String? {
        
        guard case let .input(input) = status,
              case let .failure(.serverError(warning)) = input.otpField.status
        else { return nil }
        
        return warning
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
