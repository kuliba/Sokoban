//
//  UtilityPaymentsEffect.swift
//
//
//  Created by Igor Malyarov on 19.02.2024.
//

public enum UtilityPaymentsEffect<Operator>: Equatable
where Operator: Equatable & Identifiable {
    
    case initiate
    case paginate(Operator.ID, PageSize)
    case search(String)
}

public extension UtilityPaymentsEffect {
    
    typealias PageSize = Int
}
