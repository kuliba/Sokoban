//
//  MakeAnywayTransactionPayload.swift
//  Vortex
//
//  Created by Igor Malyarov on 07.08.2024.
//

enum MakeAnywayTransactionPayload {
    
    case payment(LatestOutlinePayload)
    case oneOf(Service, Operator)
    case singleService(Service, Operator)
}

struct LatestOutlinePayload: Equatable {
    
    let md5Hash: String?
    let name: String
    let fields: [String: String]
    let puref: String
}

extension MakeAnywayTransactionPayload {
    
    typealias LastPayment = UtilityPaymentLastPayment
    typealias Operator = UtilityPaymentProvider
    typealias Service = UtilityService
}
