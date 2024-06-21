//
//  BottomFooterState+projection.swift
//
//
//  Created by Igor Malyarov on 21.06.2024.
//

import Foundation

import Foundation

extension BottomFooterState {
    
    public var projection: Projection {
        
        return .init(
            amount: amount,
            buttonTap: buttonState == .tapped ? .init() : nil
        )
    }
    
    public struct Projection: Equatable {
        
        public let amount: Decimal
        public let buttonTap: ButtonTap?
        
        public init(
            amount: Decimal,
            buttonTap: ButtonTap? = nil
        ) {
            self.amount = amount
            self.buttonTap = buttonTap
        }
        
        public struct ButtonTap: Equatable {
            
            public init() {}
        }
    }
}
