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
    
    let makeSelectView: MakeSelectView
    let makeSelectorView: MakeSelectorView
    let makeIconView: MakeIconView
}

extension AnywayPaymentParameterViewFactory {
    
    typealias MakeSelectView = (ObservingSelectViewModel) -> SelectWrapperView
    typealias MakeSelectorView = (ObservingSelectorViewModel) -> SelectorWrapperView
    typealias MakeIconView = (String) -> UIPrimitives.AsyncImage
}
