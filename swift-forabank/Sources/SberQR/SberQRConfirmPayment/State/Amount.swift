//
//  Amount.swift
//
//
//  Created by Igor Malyarov on 18.12.2023.
//

import Foundation

public extension SberQRConfirmPaymentState {
    
    struct Amount: Equatable {
        
        let title: String
        let value: Decimal
        var button: AmountButton
        
        public init(
            title: String,
            value: Decimal,
            button: AmountButton
        ) {
            self.title = title
            self.value = value
            self.button = button
        }
    }
}

public extension SberQRConfirmPaymentState.Amount {

    struct AmountButton: Equatable {
        
        let title: String
        var isEnabled: Bool
        
        public init(
            title: String,
            isEnabled: Bool
        ) {
            self.title = title
            self.isEnabled = isEnabled
        }
    }
}
