//
//  CodableServicePaymentOperator+matchesTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 06.12.2024.
//

@testable import Vortex
import XCTest

final class CodableServicePaymentOperator_matchesTests: CodableServicePaymentOperatorTests {
    
    func test_shouldNotMatchByDefault() {
        
        assertNoMatch(makeCodable(), makePayload())
    }
    
    func test_shouldNotMatchOnDifferentTypes() {
        
        assertNoMatch(
            makeCodable(type: .digitalWallets),
            makePayload(for: .security)
        )
    }
    
    func test_shouldMatchOnSameTypes() {
        
        assertMatch(
            makeCodable(type: .taxAndStateService),
            makePayload(for: .taxAndStateService)
        )
    }
    
    func test_shouldNotMatchWhenNameDoesNotContainSearchText() {
        
        assertNoMatch(
            makeCodable(
                name: "abc",
                type: .digitalWallets
            ),
            makePayload(
                for: .digitalWallets,
                searchText: "1@23"
            )
        )
    }
    
    func test_shouldMatchWhenNameContainsSearchText() {
        
        assertMatch(
            makeCodable(
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
            makeCodable(
                inn: "abc",
                type: .digitalWallets
            ),
            makePayload(
                for: .digitalWallets,
                searchText: "1@23"
            )
        )
    }
    
    func test_shouldMatchWhenInnContainsSearchText() {
        
        assertMatch(
            makeCodable(
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
            makeCodable(
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
            makeCodable(
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
            makeCodable(
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
