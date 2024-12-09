//
//  ArrayOfCodableServicePaymentOperator+pageOfOperatorsTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 06.12.2024.
//

@testable import ForaBank
import XCTest

final class ArrayOfCodableServicePaymentOperator_pageOfOperatorsTests: CodableServicePaymentOperatorTests {
    
    func test_shouldDeliverEmptyOnInvalidPageSize() {
        
        assert(
            payload: makePayload(pageSize: 0),
            on: [makeCodable()],
            delivers: []
        )
    }
    
    func test_shouldDeliverEmptyOnEmpty() {
        
        assert(
            payload: makePayload(),
            on: [],
            delivers: []
        )
    }
    
    func test_shouldDeliverEmptyOnOneWithNonMatchingType() {
        
        assert(
            payload: makePayload(for: .charity),
            on: [makeCodable(type: .education)],
            delivers: []
        )
    }
    
    func test_shouldDeliverOneOnOne() {
        
        let type: CategoryType = .education
        let codable = makeCodable(type: type)
        let `operator` = makeOperator(codable)
        
        assert(
            payload: makePayload(for: type),
            on: [codable],
            delivers: [`operator`]
        )
    }
    
    func test_shouldDeliverOneWithMatchingType() {
        
        let type: CategoryType = .education
        let codable1 = makeCodable(type: type)
        let codable2 = makeCodable(type: .digitalWallets)
        let operator1 = makeOperator(codable1)
        
        assert(
            payload: makePayload(for: type),
            on: [codable1, codable2],
            delivers: [operator1]
        )
    }
    
    func test_shouldDeliverTwoOnPageSizeTwo() {
        
        let type: CategoryType = .networkMarketing
        let codables = (0...10).map { _ in makeCodable(type: type) }
        let operators = codables.map(makeOperator)
        
        assert(
            payload: makePayload(for: type, pageSize: 2),
            on: codables,
            delivers: .init(operators.prefix(2))
        )
    }
    
    func test_shouldSkipUpUntilAfterID() {
        
        let type: CategoryType = .security
        let codables = (0...10).map { makeCodable(id: "\($0)", type: type) }
        let operators = codables.map(makeOperator)
        
        assert(
            payload: makePayload(afterOperatorID: "3", for: type, pageSize: 3),
            on: codables,
            delivers: [operators[4], operators[5], operators[6]]
        )
    }
    
    func test_shouldFilterBasedOnSearchText() {
        
        let type: CategoryType = .taxAndStateService
        let codable1 = makeCodable(name: "Electricity", type: type)
        let codable2 = makeCodable(name: "Water", type: type)
        let operator1 = makeOperator(codable1)
        
        assert(
            payload: makePayload(for: type, searchText: "Electric"),
            on: [codable1, codable2],
            delivers: [operator1]
        )
    }
    
    func test_shouldRespectOrderAfterFilter() {
        
        let type: CategoryType = .education
        let codables = (0...10).map { makeCodable(id: "\($0)", type: type) }
        let operators = codables.map(makeOperator)
        
        assert(
            payload: makePayload(for: type, pageSize: 100),
            on: codables,
            delivers: operators
        )
    }
    
    func test_shouldDeliverAllWhenPageSizeExceedsAvailable() {
        
        let type: CategoryType = .security
        let codables = (0..<3).map { makeCodable(id: "\($0)", type: type) }
        let operators = codables.map(makeOperator)
        
        assert(
            payload: makePayload(for: type, pageSize: 10),
            on: codables,
            delivers: operators
        )
    }
    
    func test_shouldDeliverEmptyWhenIDIsLast() {
        
        let type: CategoryType = .security
        let codables = (0...3).map { makeCodable(id: "\($0)", type: type) }
        let operators = codables.map(makeOperator)
        
        assert(
            payload: makePayload(afterOperatorID: "3", for: type, pageSize: 2),
            on: codables,
            delivers: []
        )
    }
    
    func test_shouldFilterIgnoringCase() {
        
        let type: CategoryType = .taxAndStateService
        let codable1 = makeCodable(name: "Electricity", type: type)
        let operator1 = makeOperator(codable1)
        
        assert(
            payload: makePayload(for: type, searchText: "electric"),
            on: [codable1],
            delivers: [operator1]
        )
    }
    
    func test_shouldDeliverOnPartialSearchTextMatch() {
        
        let type: CategoryType = .housingAndCommunalService
        let codable1 = makeCodable(name: "ElectroNetwork", type: type)
        let codable2 = makeCodable(name: "BookClub", type: type)
        let operator1 = makeOperator(codable1)
        
        assert(
            payload: makePayload(for: type, searchText: "Electro"),
            on: [codable1, codable2],
            delivers: [operator1]
        )
    }
    
    func test_shouldDeliverEmptyWhenNoSearchTextMatches() {
        
        let type: CategoryType = .security
        let codable = makeCodable(name: "Electricity", type: type)
        
        assert(
            payload: makePayload(for: type, searchText: "Gas"),
            on: [codable],
            delivers: []
        )
    }
    
    func test_shouldDeliverMultipleMatchesForSearchText() {
        
        let type: CategoryType = .education
        let codable1 = makeCodable(name: "Electricity", type: type)
        let codable2 = makeCodable(name: "ElectronicPayments", type: type)
        let operators = [codable1, codable2].map(makeOperator)
        
        assert(
            payload: makePayload(for: type, searchText: "Elect"),
            on: [codable1, codable2],
            delivers: operators
        )
    }
    
    func test_shouldDeliverEmptyWhenAfterOperatorIDDoesNotExist() {
        
        let type: CategoryType = .security
        let codables = (0...2).map { makeCodable(id: "\($0)", type: type) }
        
        assert(
            payload: makePayload(afterOperatorID: "unknown", for: type, pageSize: 2),
            on: codables,
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
