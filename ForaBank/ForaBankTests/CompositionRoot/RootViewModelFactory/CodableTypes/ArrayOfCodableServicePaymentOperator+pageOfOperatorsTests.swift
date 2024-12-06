//
//  ArrayOfCodableServicePaymentOperator+pageOfOperatorsTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 06.12.2024.
//

@testable import ForaBank
import XCTest

final class ArrayOfCodableServicePaymentOperator_pageOfOperatorsTests: CodableServicePaymentOperatorTests {
    
    func test_shouldDeliverEmptyOnEmpty() {
        
        assert(
            payload: makePayload(),
            on: [],
            delivers: []
        )
    }
    
    // MARK: - Helpers
    
    private func assert(
        payload: Payload,
        on codables: [CodableServicePaymentOperator],
        delivers expectedOperators: [PaymentServiceOperator],
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let operators = codables.pageOfOperators(for: payload)
        
        XCTAssertNoDiff(operators, expectedOperators, "Expected \(expectedOperators), but got \(operators) instead.", file: file, line: line)
    }
}
