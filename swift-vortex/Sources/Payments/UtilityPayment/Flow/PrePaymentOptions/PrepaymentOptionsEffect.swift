//
//  PrepaymentOptionsEffect.swift
//
//
//  Created by Igor Malyarov on 19.02.2024.
//

public enum PrepaymentOptionsEffect<Operator>
where Operator: Identifiable {
    
    case paginate(Operator.ID, PageSize)
    case search(String)
}

public extension PrepaymentOptionsEffect {
    
    typealias PageSize = Int
}

extension PrepaymentOptionsEffect: Equatable where Operator: Equatable {}
