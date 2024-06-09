//
//  Payment.swift
//
//
//  Created by Igor Malyarov on 07.06.2024.
//

import Foundation
import Tagged

public struct Payment<Element> {
    
    public var elements: [Element]
    public var footer: Footer
    public var infoMessage: String?
    public let isFinalStep: Bool
    public let isFraudSuspected: Bool
    public let puref: Puref
    
    public init(
        elements: [Element],
        footer: Footer,
        infoMessage: String?,
        isFinalStep: Bool,
        isFraudSuspected: Bool,
        puref: Puref
    ) {
        self.elements = elements
        self.footer = footer
        self.infoMessage = infoMessage
        self.isFinalStep = isFinalStep
        self.isFraudSuspected = isFraudSuspected
        self.puref = puref
    }
    
    public enum Footer: Equatable {
        
        case amount(Decimal)
        case `continue`
    }
    public typealias Puref = Tagged<_Puref, String>
    public enum _Puref {}
}

extension Payment: Equatable where Element: Equatable {}
