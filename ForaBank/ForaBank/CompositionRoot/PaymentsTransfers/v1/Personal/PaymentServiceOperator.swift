//
//  PaymentServiceOperator.swift
//  ForaBank
//
//  Created by Igor Malyarov on 24.09.2024.
//

struct PaymentServiceOperator: Equatable, Identifiable {
    
    let id: String
    let inn: String
    let icon: String?
    let name: String
    let type: String
}

// MARK: - Adapters

extension PaymentServiceOperator {
    
    var utilityPaymentOperator: UtilityPaymentProvider {
        
        return .init(id: id, icon: icon, inn: inn, title: name, type: type)
    }
}

extension UtilityPaymentProvider {
    
    var name: String { title }
    var subtitle: String { inn }
    
    var paymentServiceOperator: PaymentServiceOperator {
        
        return .init(id: id, inn: inn, icon: icon, name: name, type: type)
    }
}
