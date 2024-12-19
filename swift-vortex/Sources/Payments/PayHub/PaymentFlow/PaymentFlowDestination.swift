//
//  PaymentFlow.swift
//
//
//  Created by Igor Malyarov on 31.08.2024.
//

public enum PaymentFlowDestination<Mobile, Standard, Tax, Transport> {
    
    case mobile(Mobile)
    case standard(Standard)
    case taxAndStateServices(Tax)
    case transport(Transport)
}

extension PaymentFlowDestination: Equatable where Mobile: Equatable, Standard: Equatable, Tax: Equatable, Transport: Equatable {}

extension PaymentFlowDestination {
    
    public var id: PaymentFlowDestinationID {
        
        switch self {
        case .mobile:              return .mobile
        case .standard:            return .standard
        case .taxAndStateServices: return .taxAndStateServices
        case .transport:           return .transport
        }
    }
}
