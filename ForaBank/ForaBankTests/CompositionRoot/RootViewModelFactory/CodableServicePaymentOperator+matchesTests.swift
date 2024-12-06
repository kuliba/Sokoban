//
//  CodableServicePaymentOperator+matchesTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 06.12.2024.
//

@testable import ForaBank
import XCTest

final class CodableServicePaymentOperator_matchesTests: XCTestCase {
    
    func test_shouldNotMatchByDefault() {
        
        assertNoMatch(makeOperator(), makePayload())
    }
    
    func test_shouldNotMatchOnDifferentTypes() {
        
        assertNoMatch(
            makeOperator(type: .digitalWallets),
            makePayload(for: .security)
        )
    }
    
    func test_shouldMatchOnSameTypes() {
        
        assertMatch(
            makeOperator(type: .taxAndStateService),
            makePayload(for: .taxAndStateService)
        )
    }
    
    func test_shouldNotMatchWhenNameDoesNotContainSearchText() {
        
        assertNoMatch(
            makeOperator(
                name: "abc",
                type: .digitalWallets
            ),
            makePayload(
                for: .digitalWallets,
                searchText: "123"
            )
        )
    }
    
    func test_shouldMatchWhenNameContainsSearchText() {
        
        assertMatch(
            makeOperator(
                name: "abc",
                type: .taxAndStateService
            ),
            makePayload(
                for: .taxAndStateService,
                searchText: "B"
            )
        )
    }
    
    func test_shouldNotMatchWhenInnDoesNotContainSearchText() {
        
        assertNoMatch(
            makeOperator(
                inn: "abc",
                type: .digitalWallets
            ),
            makePayload(
                for: .digitalWallets,
                searchText: "123"
            )
        )
    }
    
    func test_shouldMatchWhenInnContainsSearchText() {
        
        assertMatch(
            makeOperator(
                inn: "abc",
                type: .taxAndStateService
            ),
            makePayload(
                for: .taxAndStateService,
                searchText: "b"
            )
        )
    }
    
    func test_shouldMatchOnCaseInsensitiveSearchText() {
        
        assertMatch(
            makeOperator(
                name: "ABC",
                type: .education
            ),
            makePayload(
                for: .education,
                searchText: "abc"
            )
        )
    }
    
    func test_shouldMatchIfSearchTextInBothNameAndInn() {
        
        assertMatch(
            makeOperator(
                inn: "someInnWith123",
                name: "someNameWith123",
                type: .digitalWallets
            ),
            makePayload(
                for: .digitalWallets,
                searchText: "123"
            )
        )
    }
    
    func test_shouldNotMatchIfSearchTextNotFoundInEitherNameOrInn() {
        
        assertNoMatch(
            makeOperator(
                inn: "bar",
                name: "foo",
                type: .digitalWallets
            ),
            makePayload(
                for: .digitalWallets,
                searchText: "baz"
            )
        )
    }
    
    // MARK: - Helpers
    
    private typealias Payload = UtilityPrepaymentNanoServices<PaymentServiceOperator>.LoadOperatorsPayload
    
    private func makeOperator(
        id: String = anyMessage(),
        inn: String = anyMessage(),
        md5Hash: String? = anyMessage(),
        name: String = anyMessage(),
        type: ServiceCategory.CategoryType = .repaymentLoansAndAccounts,
        sortedOrder: Int = .random(in: 1...100)
    ) -> CodableServicePaymentOperator {
        
        return .init(id: id, inn: inn, md5Hash: md5Hash, name: name, type: type.name, sortedOrder: sortedOrder)
    }
    
    private func makePayload(
        afterOperatorID id: String? = nil,
        for type: ServiceCategory.CategoryType = .internet,
        searchText: String = "",
        pageSize: Int = 3
    ) -> Payload {
        
        return .init(afterOperatorID: id, for: type, searchText: searchText, pageSize: pageSize)
    }
    
    private func assertMatch(
        _ codable: CodableServicePaymentOperator,
        _ payload: Payload,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertTrue(codable.matches(payload), "\(codable) does not match payload \(payload).", file: file, line: line)
    }
    
    private func assertNoMatch(
        _ codable: CodableServicePaymentOperator,
        _ payload: Payload,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertFalse(codable.matches(payload), "\(codable) does match payload \(payload).", file: file, line: line)
    }
}
