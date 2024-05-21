//
//  AnywayPaymentFactory.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 21.05.2024.
//

import AnywayPaymentDomain

struct AnywayPaymentFactory {
    
    let makeElementView: MakeElementView
}

extension AnywayPaymentFactory {
    
    typealias Element = AnywayPayment.Element
    typealias MakeElementView = (Element) -> AnywayPaymentElementView
}
