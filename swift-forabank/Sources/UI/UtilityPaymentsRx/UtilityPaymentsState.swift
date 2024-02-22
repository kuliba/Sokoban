//
//  UtilityPaymentsState.swift
//
//
//  Created by Igor Malyarov on 19.02.2024.
//

public struct UtilityPaymentsState<LastPayment, Operator>: Equatable
where LastPayment: Equatable & Identifiable,
      Operator: Equatable & Identifiable {
    
    public var lastPayments: [LastPayment]?
    public var operators: [Operator]?
    public var searchText: String
    public var status: Status?
    
    public init(
        lastPayments: [LastPayment]? = nil,
        operators: [Operator]? = nil,
        searchText: String = "",
        status: Status? = nil
    ) {
        self.lastPayments = lastPayments
        self.operators = operators
        self.searchText = searchText
        self.status = status
    }
}

public extension UtilityPaymentsState {
    
    enum Status: Equatable {
        
        case inflight
        case failure(ServiceFailure)
    }
}
