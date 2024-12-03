//
//  RootViewModelFactory+getPaymentsTransfersCorporateNavigationTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 01.12.2024.
//

@testable import ForaBank
import XCTest

final class RootViewModelFactory_getPaymentsTransfersCorporateNavigationTests: RootViewModelFactoryTests {
    
    // MARK: - userAccount
    
    func test_userAccount_shouldDeliverUserAccount() {
        
        expect(.userAccount, toDeliver: .userAccount)
    }
    
    // MARK: - Helpers
    
    private typealias Domain = ForaBank.PaymentsTransfersCorporateDomain
    
    private func expect(
        sut: SUT? = nil,
        _ select: Domain.Select,
        toDeliver expectedNavigation: Domain.Navigation,
        timeout: TimeInterval = 1.0,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT().sut
        let exp = expectation(description: "wait for get navigation completion")
        
        sut.getPaymentsTransfersCorporateNavigation(
            select: select, 
            notify: { _ in }
        ) {
            XCTAssertNoDiff($0, expectedNavigation, "Expected \(expectedNavigation), but got \($0) instead.", file: file, line: line)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: timeout)
    }
}
