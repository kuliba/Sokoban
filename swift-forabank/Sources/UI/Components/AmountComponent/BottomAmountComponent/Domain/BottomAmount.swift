//
//  BottomAmount.swift
//
//
//  Created by Igor Malyarov on 18.12.2023.
//

import Foundation

public struct BottomAmount: Equatable {
    
    public var value: Decimal
    public var button: AmountButton
    public var status: Status?
    
    public init(
        value: Decimal = 0,
        button: AmountButton,
        status: Status?
    ) {
        self.value = value
        self.button = button
        self.status = status
    }
}

public extension BottomAmount {

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
    
    enum Status: Equatable {
        
        case tapped
    }
}
