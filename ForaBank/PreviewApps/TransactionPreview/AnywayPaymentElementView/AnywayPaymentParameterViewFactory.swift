//
//  AnywayPaymentParameterViewFactory.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 23.05.2024.
//

import AnywayPaymentDomain

struct AnywayPaymentParameterViewFactory {
    
    let makeSelectorView: MakeSelectorView
}

extension AnywayPaymentParameterViewFactory {
    
    typealias Option = AnywayPayment.Element.UIComponent.Parameter.ParameterType.Option
    typealias Observe = (Selector<Option>) -> Void
    typealias MakeSelectorView = (Selector<Option>, @escaping  Observe) -> SelectorWrapperView
}
