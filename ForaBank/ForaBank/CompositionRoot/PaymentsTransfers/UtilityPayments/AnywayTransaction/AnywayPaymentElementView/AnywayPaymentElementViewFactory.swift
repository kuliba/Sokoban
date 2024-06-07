//
//  AnywayPaymentElementViewFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.05.2024.
//

import AnywayPaymentDomain

struct AnywayPaymentElementViewFactory<IconView> {

    let makeIconView: MakeIconView
    let parameterFactory: AnywayPaymentParameterViewFactory
}

extension AnywayPaymentElementViewFactory {
    
    typealias AnywayPayment = AnywayPaymentDomain.AnywayPayment
    
    typealias Element = AnywayElement.UIComponent
    typealias MakeIconView = (Element) -> IconView
}
