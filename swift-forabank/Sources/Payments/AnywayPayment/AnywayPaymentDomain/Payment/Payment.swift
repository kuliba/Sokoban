//
//  Payment.swift
//
//
//  Created by Igor Malyarov on 07.06.2024.
//

import Foundation

public struct Payment<Element> {
    
    public var elements: [Element]
    public var footer: Footer
    public var infoMessage: String?
    public let isFinalStep: Bool
    public let isFraudSuspected: Bool
    
    public init(
        elements: [Element],
        footer: Footer,
        infoMessage: String?,
        isFinalStep: Bool,
        isFraudSuspected: Bool
    ) {
        self.elements = elements
        self.footer = footer
        self.infoMessage = infoMessage
        self.isFinalStep = isFinalStep
        self.isFraudSuspected = isFraudSuspected
    }
    
    public enum Footer: Equatable {
        
        case amount(Decimal)
        case `continue`
    }
}

extension Payment: Equatable where Element: Equatable {}
