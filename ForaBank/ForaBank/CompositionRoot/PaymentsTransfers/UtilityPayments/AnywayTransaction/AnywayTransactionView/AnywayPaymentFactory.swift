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
    
    typealias Element = AnywayTransactionState.IdentifiedModel
    typealias MakeElementView = (Element) -> AnywayPaymentElementView<IconView>
    
    typealias MakeFooterView = (AnywayTransactionState, @escaping (AnywayPaymentFooterEvent) -> Void) -> AnywayPaymentFooterView
}
