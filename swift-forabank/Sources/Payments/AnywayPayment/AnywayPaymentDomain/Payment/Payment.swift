//
//  Payment.swift
//
//
//  Created by Igor Malyarov on 07.06.2024.
//

import Tagged

public struct Payment<Element> {
    
    public var elements: [Element]
    public var infoMessage: String?
    public let isFinalStep: Bool
    public let isFraudSuspected: Bool
    public let puref: Puref
    
    public init(
        elements: [Element],
        infoMessage: String?,
        isFinalStep: Bool,
        isFraudSuspected: Bool,
        puref: Puref
    ) {
        self.elements = elements
        self.infoMessage = infoMessage
        self.isFinalStep = isFinalStep
        self.isFraudSuspected = isFraudSuspected
        self.puref = puref
    }
    
    public typealias Puref = Tagged<_Puref, String>
    public enum _Puref {}
    
    public enum Status: Equatable {
        
        case infoMessage(String)
    }
}

extension Payment: Equatable where Element: Equatable {}
