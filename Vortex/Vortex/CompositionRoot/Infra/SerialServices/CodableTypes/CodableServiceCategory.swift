//
//  CodableServiceCategory.swift
//  Vortex
//
//  Created by Igor Malyarov on 11.09.2024.
//

import Foundation

extension Array where Element == ServiceCategory {
    
    init(codable: [CodableServiceCategory]) {
        
        self = codable.map(ServiceCategory.init(codable:))
    }
}

extension Array where Element == CodableServiceCategory {
    
    init(categories: [ServiceCategory]) {
        
        self = categories.map(\.codable)
    }
}

struct CodableServiceCategory: Codable {
    
    let latestPaymentsCategory: LatestPaymentsCategory?
    let md5Hash: String
    let name: String
    let ord: Int
    let paymentFlow: PaymentFlow
    let hasSearch: Bool
    let type: CategoryType
    
    typealias CategoryType = String
    typealias LatestPaymentsCategory = String
    
    enum PaymentFlow: Codable {
        
        case mobile
        case qr
        case standard
        case taxAndStateServices
        case transport
    }
}

extension ServiceCategory {
    
    var codable: CodableServiceCategory {
        
        return .init(
            latestPaymentsCategory: latestPaymentsCategory,
            md5Hash: md5Hash,
            name: name,
            ord: ord,
            paymentFlow: codablePaymentFlow,
            hasSearch: hasSearch,
            type: type
        )
    }
}

private extension ServiceCategory {
    
    init(codable: CodableServiceCategory) {
        
        self.init(
            latestPaymentsCategory: codable.latestPaymentsCategory,
            md5Hash: codable.md5Hash,
            name: codable.name,
            ord: codable.ord,
            paymentFlow: codable.flow,
            hasSearch: codable.hasSearch,
            type: codable.type
        )
    }
    
    
    private var codablePaymentFlow: CodableServiceCategory.PaymentFlow {
        
        switch paymentFlow {
        case .mobile:               return .mobile
        case .qr:                   return .qr
        case .standard:             return .standard
        case .taxAndStateServices:  return .taxAndStateServices
        case .transport:            return .transport
        }
    }
}

extension CodableServiceCategory {
    
    var serviceCategory: ServiceCategory {
        
        return .init(
            latestPaymentsCategory: latestPaymentsCategory,
            md5Hash: md5Hash,
            name: name,
            ord: ord,
            paymentFlow: flow,
            hasSearch: hasSearch,
            type: type
        )
    }
}

private extension CodableServiceCategory {
    
    var flow: ServiceCategory.PaymentFlow {
        
        switch paymentFlow {
        case .mobile:               return .mobile
        case .qr:                   return .qr
        case .standard:             return .standard
        case .taxAndStateServices:  return .taxAndStateServices
        case .transport:            return .transport
        }
    }
}
