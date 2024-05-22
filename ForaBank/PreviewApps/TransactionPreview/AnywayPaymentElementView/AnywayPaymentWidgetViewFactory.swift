//
//  AnywayPaymentWidgetViewFactory.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 21.05.2024.
//

import AnywayPaymentDomain

struct AnywayPaymentWidgetViewFactory {
    
    let makeProductSelectView: MakeProductSelectView
}

extension AnywayPaymentWidgetViewFactory {
    
    typealias MakeProductSelectView = (ProductID, @escaping Observe) -> ProductSelectStateWrapperView
    typealias Observe = (ProductID, Currency) -> Void
    typealias ProductID = AnywayPayment.Element.UIComponent.Widget.ProductID
    typealias Currency = AnywayPaymentEvent.Widget.Currency
}
