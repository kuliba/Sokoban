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
