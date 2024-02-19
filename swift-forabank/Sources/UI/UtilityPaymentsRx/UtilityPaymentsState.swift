//
//  UtilityPaymentsState.swift
//
//
//  Created by Igor Malyarov on 19.02.2024.
//

public struct UtilityPaymentsState: Equatable {
    
    public var lastPayments: [LastPayment]?
    public var operators: [Operator]?
    public var status: Status?
    
    public init(
        lastPayments: [LastPayment]? = nil,
        operators: [Operator]? = nil,
        status: Status? = nil
    ) {
        self.lastPayments = lastPayments
        self.operators = operators
        self.status = status
    }
}

public extension UtilityPaymentsState {
    
    enum Status: Equatable {
        
        case inflight
        case failure(ServiceFailure)
    }
}
