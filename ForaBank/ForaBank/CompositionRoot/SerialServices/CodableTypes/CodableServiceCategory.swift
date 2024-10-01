//
//  CodableServiceCategory.swift
//  ForaBank
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
    
    enum CategoryType: Codable {
        
        case charity
        case digitalWallets
        case education
        case housingAndCommunalService
        case internet
        case mobile
        case networkMarketing
        case qr
        case repaymentLoansAndAccounts
        case security
        case socialAndGames
        case transport
        case taxAndStateService
    }
    
    enum LatestPaymentsCategory: Codable {
        
        case charity
        case education
        case digitalWallets
        case internet
        case mobile
        case networkMarketing
        case repaymentLoansAndAccounts
        case security
        case service
        case socialAndGames
        case taxAndStateService
        case transport
    }
    
    enum PaymentFlow: Codable {
        
        case mobile
        case qr
        case standard
        case taxAndStateServices
        case transport
    }
}

private extension ServiceCategory {
    
    init(codable: CodableServiceCategory) {
        
        self.init(
            latestPaymentsCategory: codable.latestCategory,
            md5Hash: codable.md5Hash,
            name: codable.name,
            ord: codable.ord,
            paymentFlow: codable.flow,
            hasSearch: codable.hasSearch,
            type: codable.category
        )
    }
    
    var codable: CodableServiceCategory {
        
        return .init(
            latestPaymentsCategory: codableLatestPaymentsCategory,
            md5Hash: md5Hash,
            name: name,
            ord: ord,
            paymentFlow: codablePaymentFlow,
            hasSearch: hasSearch,
            type: codableType
        )
    }
    
    private var codableLatestPaymentsCategory: CodableServiceCategory.LatestPaymentsCategory? {
        
        switch latestPaymentsCategory {
        case .none:                        return .none
        case .charity:                     return .charity
        case .education:                   return .education
        case .digitalWallets:              return .digitalWallets
        case .internet:                    return .internet
        case .mobile:                      return .mobile
        case .networkMarketing:            return .networkMarketing
        case .repaymentLoansAndAccounts:   return .repaymentLoansAndAccounts
        case .security:                    return .security
        case .service:                     return .service
        case .socialAndGames:              return .socialAndGames
        case .taxAndStateService:          return .taxAndStateService
        case .transport:                   return .transport
        }
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
    
    private var codableType: CodableServiceCategory.CategoryType {
        
        switch type {
        case .charity:                     return .charity
        case .digitalWallets:              return .digitalWallets
        case .education:                   return .education
        case .housingAndCommunalService:   return .housingAndCommunalService
        case .internet:                    return .internet
        case .mobile:                      return .mobile
        case .networkMarketing:            return .networkMarketing
        case .qr:                          return .qr
        case .repaymentLoansAndAccounts:   return .repaymentLoansAndAccounts
        case .security:                    return .security
        case .socialAndGames:              return .socialAndGames
        case .transport:                   return .transport
        case .taxAndStateService:          return .taxAndStateService
        }
    }
}

private extension CodableServiceCategory {
    
    var category: ServiceCategory.CategoryType {
        
        switch type {
        case .charity:                     return .charity
        case .digitalWallets:              return .digitalWallets
        case .education:                   return .education
        case .housingAndCommunalService:   return .housingAndCommunalService
        case .internet:                    return .internet
        case .mobile:                      return .mobile
        case .networkMarketing:            return .networkMarketing
        case .qr:                          return .qr
        case .repaymentLoansAndAccounts:   return .repaymentLoansAndAccounts
        case .security:                    return .security
        case .socialAndGames:              return .socialAndGames
        case .transport:                   return .transport
        case .taxAndStateService:          return .taxAndStateService
        }
    }
    
    var latestCategory: ServiceCategory.LatestPaymentsCategory? {
        
        switch latestPaymentsCategory {
        case .none:                        return .none
        case .charity:                     return .charity
        case .education:                   return .education
        case .digitalWallets:              return .digitalWallets
        case .internet:                    return .internet
        case .mobile:                      return .mobile
        case .networkMarketing:            return .networkMarketing
        case .repaymentLoansAndAccounts:   return .repaymentLoansAndAccounts
        case .security:                    return .security
        case .service:                     return .service
        case .socialAndGames:              return .socialAndGames
        case .taxAndStateService:          return .taxAndStateService
        case .transport:                   return .transport
        }
    }
    
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
