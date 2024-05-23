//
//  AnywayPaymentElementViewFactory.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 21.05.2024.
//

import AnywayPaymentDomain

struct AnywayPaymentElementViewFactory<IconView> {

    let makeIconView: MakeIconView
    let makeProductSelectView: MakeProductSelectView
}

extension AnywayPaymentElementViewFactory {
    
    typealias Element = AnywayPayment.Element.UIComponent
    typealias MakeIconView = (Element) -> IconView
    
    typealias MakeProductSelectView = (ProductID, @escaping Observe) -> ProductSelectStateWrapperView
    typealias Observe = (ProductID, Currency) -> Void
    typealias ProductID = AnywayPayment.Element.UIComponent.Widget.ProductID
    typealias Currency = AnywayPaymentEvent.Widget.Currency
}
