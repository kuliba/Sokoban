//
//  AnywayPaymentElementViewFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.05.2024.
//

import UIPrimitives

struct AnywayPaymentElementViewFactory {

    let makeIconView: MakeIconView
    let parameterFactory: AnywayPaymentParameterViewFactory
    let widgetFactory: AnywayPaymentWidgetViewFactory
}

extension AnywayPaymentElementViewFactory {
        
    typealias MakeIconView = (String) -> UIPrimitives.AsyncImage
}
