//
//  AnywayPaymentElementViewFactory.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 21.05.2024.
//

import AnywayPaymentDomain

struct AnywayPaymentElementViewFactory<IconView> {

    let makeIconView: MakeIconView
    let widget: AnywayPaymentWidgetViewFactory
}

extension AnywayPaymentElementViewFactory {
    
    typealias Element = AnywayPayment.Element.UIComponent
    typealias MakeIconView = (Element) -> IconView
}
