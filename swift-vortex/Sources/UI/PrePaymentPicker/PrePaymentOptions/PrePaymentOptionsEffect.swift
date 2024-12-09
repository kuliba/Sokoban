//
//  PrePaymentOptionsEffect.swift
//
//
//  Created by Igor Malyarov on 19.02.2024.
//

@available(*, deprecated, message: "Use `PrepaymentOptionsEffect` from `UtilityPayment` module")
public enum PrePaymentOptionsEffect<Operator>
where Operator: Identifiable {
    
    case initiate
    case paginate(Operator.ID, PageSize)
    case search(String)
}

public extension PrePaymentOptionsEffect {
    
    typealias PageSize = Int
}

extension PrePaymentOptionsEffect: Equatable where Operator: Equatable {}
