//
//  UtilityPaymentsEvent.swift
//
//
//  Created by Igor Malyarov on 19.02.2024.
//

public enum UtilityPaymentsEvent: Equatable {
    
    case didScrollTo(Operator.ID)
    case initiate
    case loaded(Loaded)
    case paginated(LoadOperatorsResult)
    case search(Search)
}

public extension UtilityPaymentsEvent {
    
    enum Loaded: Equatable {
        
        case lastPayments(LoadLastPaymentsResult)
        case operators(LoadOperatorsResult)
    }
    
    enum Search: Equatable {
        
        case entered(String)
        case updated(String)
    }
}
