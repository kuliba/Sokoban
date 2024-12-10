//
//  PaymentServiceOperator.swift
//  ForaBank
//
//  Created by Igor Malyarov on 24.09.2024.
//

struct PaymentServiceOperator: Equatable, Identifiable {
    
    let id: String
    let inn: String
    let md5Hash: String?
    let name: String
    let type: String
}

// MARK: - Adapters

extension PaymentServiceOperator {
    
    var utilityPaymentOperator: UtilityPaymentOperator {
        
        return .init(id: id, icon: md5Hash, inn: inn, title: name, type: type)
    }
}

extension UtilityPaymentOperator {
    
    var md5Hash: String? { icon }
    var name: String { title }
    var subtitle: String { inn }
    
    var paymentServiceOperator: PaymentServiceOperator {
        
        return .init(id: id, inn: inn, md5Hash: md5Hash, name: name, type: type)
    }
}
