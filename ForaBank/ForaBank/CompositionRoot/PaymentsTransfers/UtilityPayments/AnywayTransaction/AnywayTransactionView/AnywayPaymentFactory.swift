//
//  AnywayPaymentFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.05.2024.
//

import AnywayPaymentCore
import AnywayPaymentDomain
import SwiftUI

struct AnywayPaymentFactory<IconView: View> {
    
    let makeElementView: MakeElementView
    let makeFooterView: MakeFooterView
}

extension AnywayPaymentFactory {
    
    typealias Element = CachedAnywayPayment<AnywayElementModel>.IdentifiedModel
    typealias MakeElementView = (Element) -> AnywayPaymentElementView<IconView>
    
    typealias MakeFooterView = (CachedTransactionState, @escaping (AnywayPaymentFooterEvent) -> Void) -> AnywayPaymentFooterView
}
