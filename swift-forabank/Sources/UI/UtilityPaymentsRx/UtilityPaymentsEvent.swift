//
//  UtilityPaymentsEvent.swift
//
//
//  Created by Igor Malyarov on 19.02.2024.
//

public enum UtilityPaymentsEvent {
    
    case initiate
    case loaded(Loaded)
}

public extension UtilityPaymentsEvent {
    
    enum Loaded: Equatable {
        
        case lastPayments(LoadLastPaymentsResult)
        case operators(LoadOperatorsResult)
    }
}

extension UtilityPaymentsEvent: Equatable {}
