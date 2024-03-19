//
//  PrepaymentOptionsEvent.swift
//
//
//  Created by Igor Malyarov on 19.02.2024.
//

public enum PrepaymentOptionsEvent<LastPayment, Operator>
where Operator: Identifiable {
    
    case didScrollTo(Operator.ID)
    case paginated(LoadOperatorsResult)
    #warning("fix search")
    case search(Search)
}

public extension PrepaymentOptionsEvent {
    
    typealias LoadOperatorsResult = Result<[Operator], ServiceFailure>
    
    enum Search: Equatable {
        
        case entered(String)
        case updated(String)
    }
}

extension PrepaymentOptionsEvent: Equatable where LastPayment: Equatable, Operator: Equatable {}
