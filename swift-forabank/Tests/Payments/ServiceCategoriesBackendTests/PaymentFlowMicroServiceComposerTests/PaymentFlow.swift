//
//  PaymentFlow.swift
//
//
//  Created by Igor Malyarov on 31.08.2024.
//

public enum PaymentFlow<Mobile, QR, Standard, Tax, Transport> {
    
    case mobile(Mobile)
    case qr(QR)
    case standard(Standard)
    case taxAndStateServices(Tax)
    case transport(Transport)
}

extension PaymentFlow: Equatable where Mobile: Equatable, QR: Equatable, Standard: Equatable, Tax: Equatable, Transport: Equatable {}

extension PaymentFlow {
    
    public var id: ID {
        
        switch self {
        case .mobile:              return .mobile
        case .qr:                  return .qr
        case .standard:            return .standard
        case .taxAndStateServices: return .taxAndStateServices
        case .transport:           return .transport
        }
    }
    
    public enum ID: Hashable {
        
        case mobile
        case qr
        case standard
        case taxAndStateServices
        case transport
    }
}
