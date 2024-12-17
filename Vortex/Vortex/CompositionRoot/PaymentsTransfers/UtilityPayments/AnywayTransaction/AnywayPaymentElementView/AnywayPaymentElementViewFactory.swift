//
//  AnywayPaymentElementViewFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.05.2024.
//

import AnywayPaymentDomain
import UIPrimitives

struct AnywayPaymentElementViewFactory {

    let makeIconView: MakeIconView
    let parameterFactory: AnywayPaymentParameterViewFactory
    let widgetFactory: AnywayPaymentWidgetViewFactory
}

extension AnywayPaymentElementViewFactory {
        
    typealias Icon = AnywayPaymentDomain.AnywayElement.UIComponent.Icon
    typealias MakeIconView = (Icon?) -> UIPrimitives.AsyncImage
}
