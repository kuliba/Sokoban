//
//  Amount.swift
//
//
//  Created by Igor Malyarov on 18.12.2023.
//

import Foundation

public struct Amount: Equatable {
    
    public let title: String
    public let value: Decimal
    public var button: AmountButton
    
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

public extension Amount {

    struct AmountButton: Equatable {
        
        public let title: String
        public var isEnabled: Bool
        
        public init(
            title: String,
            isEnabled: Bool
        ) {
            self.title = title
            self.isEnabled = isEnabled
        }
    }
}
