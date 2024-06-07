//
//  AnywayPayment.swift
//
//
//  Created by Igor Malyarov on 06.04.2024.
//

import Tagged

public struct AnywayPayment: Equatable {
    
    public var elements: [AnywayElement]
    public var infoMessage: String?
    public let isFinalStep: Bool
    public let isFraudSuspected: Bool
    public let puref: Puref
    
    public init(
        elements: [AnywayElement],
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
}

extension AnywayPayment {
    
    public typealias Puref = Tagged<_Puref, String>
    public enum _Puref {}
    
    public enum Status: Equatable {
        
        case infoMessage(String)
    }
}
