//
//  TestHelpers.swift
//
//
//  Created by Igor Malyarov on 20.02.2024.
//

import Tagged
import PrePaymentPicker

struct TestLastPayment: Equatable & Identifiable {
    
    var id: String
}

struct TestOperator: Equatable & Identifiable {
    
    var id: String
}

extension Array where Element == TestLastPayment {
    
    static let stub: Self = (0..<10)
        .map { $0 }
        .map(String.init)
        .map { .init(id: $0) }
}

extension Array where Element == TestOperator {
    
    static let stub: Self = (0..<10)
        .map { $0 }
        .map(String.init)
        .map { .init(id: $0) }
}
