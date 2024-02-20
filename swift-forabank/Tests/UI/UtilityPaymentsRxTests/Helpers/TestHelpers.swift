//
//  TestHelpers.swift
//
//
//  Created by Igor Malyarov on 20.02.2024.
//

import Tagged
import UtilityPaymentsRx

extension Array where Element == LastPayment {
    
    static let stub: Self = (0..<10)
        .map { $0 }
        .map(String.init)
        .map { .init(id: .init($0)) }
}

extension Array where Element == Operator {
    
    static let stub: Self = (0..<10)
        .map { $0 }
        .map(String.init)
        .map { .init(id: .init($0)) }
}
