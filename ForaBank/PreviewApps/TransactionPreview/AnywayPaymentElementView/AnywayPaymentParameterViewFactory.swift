//
//  AnywayPaymentParameterViewFactory.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 23.05.2024.
//

import AnywayPaymentDomain
import PaymentComponents

struct AnywayPaymentParameterViewFactory {
    
    let makeSelectorView: MakeSelectorView
    let makeTextInputView: MakeTextInputView
}

extension AnywayPaymentParameterViewFactory {
    
    typealias Option = AnywayElement.UIComponent.Parameter.ParameterType.Option
    typealias ObserveSelector = (Selector<Option>) -> Void
    typealias MakeSelectorView = (Selector<Option>, @escaping  ObserveSelector) -> SelectorWrapperView
    
    typealias Parameter = AnywayElement.UIComponent.Parameter
    typealias ObserveInput = (InputState<String>) -> Void
    typealias MakeTextInputView = (Parameter, @escaping ObserveInput) -> InputStateWrapperView
}
