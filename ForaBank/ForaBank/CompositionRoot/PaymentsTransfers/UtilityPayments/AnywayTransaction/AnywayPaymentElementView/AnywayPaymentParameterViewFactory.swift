//
//  AnywayPaymentParameterViewFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.05.2024.
//

import AnywayPaymentDomain
import PaymentComponents
import UIPrimitives

struct AnywayPaymentParameterViewFactory {
    
    let makeSelectorView: MakeSelectorView
    let makeIconView: MakeIconView
}

extension AnywayPaymentParameterViewFactory {
    
    typealias AnywayPayment = AnywayPaymentDomain.AnywayPayment
    
    typealias Option = AnywayElement.UIComponent.Parameter.ParameterType.Option
    typealias MakeSelectorView = (ObservingSelectorViewModel<Option>) -> SelectorWrapperView
    
    typealias MakeIconView = (String) -> UIPrimitives.AsyncImage
}
