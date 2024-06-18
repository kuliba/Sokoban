//
//  AmountView+ext.swift
//
//
//  Created by Igor Malyarov on 08.06.2024.
//

import Foundation
import SwiftUI

public extension AmountView where InfoView == EmptyView {
    
    @available(*, deprecated, message: "use `init with `AmountEvent``")
    init(
        amount: Amount,
        event: @escaping (Decimal) -> Void,
        pay: @escaping () -> Void,
        currencySymbol: String,
        config: AmountConfig
    ) {
        self.init(
            amount: amount,
            event: {
                switch $0 {
                case let .edit(value):
                    event(value)
                    
                case .pay:
                    pay()
                }
            },
            currencySymbol: currencySymbol,
            config: config,
            infoView: { .init() }
        )
    }
}
