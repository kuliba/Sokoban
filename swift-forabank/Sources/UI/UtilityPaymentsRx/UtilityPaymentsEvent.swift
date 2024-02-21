//
//  UtilityPaymentsEvent.swift
//
//
//  Created by Igor Malyarov on 19.02.2024.
//

public enum UtilityPaymentsEvent<LastPayment, Operator>: Equatable
where LastPayment: Equatable & Identifiable,
      Operator: Equatable & Identifiable {
    
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
    
    typealias LoadLastPaymentsResult = Result<[LastPayment], ServiceFailure>
    typealias LoadOperatorsResult = Result<[Operator], ServiceFailure>
    
    enum Search: Equatable {
        
        case entered(String)
        case updated(String)
    }
}
