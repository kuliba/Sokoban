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
    public let payload: Payload
    
    public init(
        elements: [Element],
        footer: Footer,
        infoMessage: String?,
        isFinalStep: Bool,
        isFraudSuspected: Bool,
        payload: Payload
    ) {
        self.elements = elements
        self.footer = footer
        self.infoMessage = infoMessage
        self.isFinalStep = isFinalStep
        self.isFraudSuspected = isFraudSuspected
        self.payload = payload
    }
    
    public enum Footer: Equatable {
        
        case amount(Decimal)
        case `continue`
    }

    public struct Payload: Equatable {
        
        public let puref: Puref
        public let title: String
        public let subtitle: String?
        public let icon: String?
        
        public init(
            puref: Puref, 
            title: String, 
            subtitle: String?,
            icon: String?
        ) {
            self.puref = puref
            self.title = title
            self.subtitle = subtitle
            self.icon = icon
        }
        
        public typealias Puref = String
    }
}

extension Payment: Equatable where Element: Equatable {}
