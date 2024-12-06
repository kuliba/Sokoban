//
//  ArrayOfCodableServicePaymentOperator+pageOfOperatorsTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 06.12.2024.
//

@testable import ForaBank
import XCTest

final class ArrayOfCodableServicePaymentOperator_pageOfOperatorsTests: XCTestCase {
    
    func test_shouldDeliverEmptyOnEmpty() {
        
        assert(
            payload: makePayload(),
            on: [],
            delivers: []
        )
    }
    
    // MARK: - Helpers
    
    private typealias Payload = UtilityPrepaymentNanoServices<PaymentServiceOperator>.LoadOperatorsPayload
    
    private func makePayload(
        afterOperatorID id: String? = nil,
        for type: ServiceCategory.CategoryType = .internet,
        searchText: String = "",
        pageSize: Int = 3
    ) -> Payload {
        
        return .init(afterOperatorID: id, for: type, searchText: searchText, pageSize: pageSize)
    }
    
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
