//
//  Payment.swift
//
//
//  Created by Igor Malyarov on 07.06.2024.
//

import Foundation

public struct Payment<Element> {
    
    public var amount: Decimal?
    public var elements: [Element]
    public var footer: Footer
    public let isFinalStep: Bool
    
    public init(
        amount: Decimal?,
        elements: [Element],
        footer: Footer,
        isFinalStep: Bool
    ) {
        self.amount = amount
        self.elements = elements
        self.footer = footer
        self.isFinalStep = isFinalStep
    }
    
    public enum Footer: Equatable {
        
        case amount, `continue`
    }
}

extension Payment: Equatable where Element: Equatable {}
