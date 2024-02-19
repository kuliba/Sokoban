//
//  UtilityPaymentsState.swift
//
//
//  Created by Igor Malyarov on 19.02.2024.
//

public struct UtilityPaymentsState {
    
    public var lastPayments: LastPayments?
    public var operators: Operators?
    public var status: Status?
    
    public init(
        lastPayments: LastPayments? = nil, 
        operators: Operators? = nil,
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

extension UtilityPaymentsState: Equatable {}
