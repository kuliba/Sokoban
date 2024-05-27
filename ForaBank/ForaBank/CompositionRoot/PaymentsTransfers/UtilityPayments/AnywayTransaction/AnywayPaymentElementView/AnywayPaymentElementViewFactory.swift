//
//  AnywayPaymentElementViewFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.05.2024.
//

import AnywayPaymentDomain

struct AnywayPaymentElementViewFactory<IconView> {

    let makeIconView: MakeIconView
    let makeProductSelectView: MakeProductSelectView
    let elementFactory: AnywayPaymentParameterViewFactory
}

extension AnywayPaymentElementViewFactory {
    
    typealias AnywayPayment = AnywayPaymentDomain.AnywayPayment
    
    typealias Element = AnywayPayment.Element.UIComponent
    typealias MakeIconView = (Element) -> IconView
    
    typealias MakeProductSelectView = (ProductID, @escaping Observe) -> ProductSelectStateWrapperView
    typealias Observe = (ProductID, Currency) -> Void
    typealias ProductID = AnywayPayment.Element.UIComponent.Widget.ProductID
    typealias Currency = AnywayPaymentEvent.Widget.Currency
}
