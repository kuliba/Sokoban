//
//  PrePaymentOptionsEvent.swift
//
//
//  Created by Igor Malyarov on 19.02.2024.
//

@available(*, deprecated, message: "Use `PrepaymentOptionsEvent` from `UtilityPayment` module")
public enum PrePaymentOptionsEvent<LastPayment, Operator>
where Operator: Identifiable {
    
    case didScrollTo(Operator.ID)
    case initiate
    case loaded(LoadLastPaymentsResult, LoadOperatorsResult)
    case paginated(LoadOperatorsResult)
    case search(Search)
}

public extension PrePaymentOptionsEvent {
    
    typealias LoadLastPaymentsResult = Result<[LastPayment], ServiceFailure>
    typealias LoadOperatorsResult = Result<[Operator], ServiceFailure>
    
    enum Search: Equatable {
        
        case entered(String)
        case updated(String)
    }
}

extension PrePaymentOptionsEvent: Equatable where LastPayment: Equatable, Operator: Equatable {}
