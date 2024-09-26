//
//  MakeAnywayTransactionPayload.swift
//  ForaBank
//
//  Created by Igor Malyarov on 07.08.2024.
//

enum MakeAnywayTransactionPayload {
    
    case lastPayment(LastPayment)
    case oneOf(Service, Operator)
    case singleService(Service, Operator)
}

extension MakeAnywayTransactionPayload {
    
    typealias LastPayment = UtilityPaymentLastPayment
    typealias Operator = UtilityPaymentOperator
    typealias Service = UtilityService
}
