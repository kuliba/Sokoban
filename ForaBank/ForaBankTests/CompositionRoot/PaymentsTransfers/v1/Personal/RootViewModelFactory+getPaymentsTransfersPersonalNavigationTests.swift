//
//  RootViewModelFactory+getPaymentsTransfersPersonalNavigationTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 01.12.2024.
//

@testable import ForaBank
import XCTest

final class RootViewModelFactory_getPaymentsTransfersPersonalNavigationTests: RootViewModelFactoryTests {
    
    // MARK: - byPhoneTransfer
    
    func test_byPhoneTransfer_shouldDeliverTemplates() {
        
        expect(.byPhoneTransfer, toDeliver: .byPhoneTransfer)
    }
    
    // MARK: - main
    
    func test_main_shouldDeliverTemplates() {
        
        expect(.main, toDeliver: .main)
    }
    
    // MARK: - scanQR
    
    func test_scanQR_shouldDeliverTemplates() {
        
        expect(.scanQR, toDeliver: .scanQR)
    }
    
    // MARK: - standardPayment
    
    func test_standardPayment_shouldDeliverTemplates() {
        
        expect(.standardPayment, toDeliver: .standardPayment)
    }
    
    // MARK: - templates
    
    func test_templates_shouldDeliverTemplates() {
        
        expect(.templates, toDeliver: .templates)
    }
    
    // MARK: - userAccount
    
    func test_userAccount_shouldDeliverUserAccount() {
        
        expect(.userAccount, toDeliver: .userAccount)
    }
    
    // MARK: - Helpers
    
    private typealias Domain = ForaBank.PaymentsTransfersPersonalDomain
    
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
        
        sut.getPaymentsTransfersPersonalNavigation(
            select: select,
            notify: { _ in }
        ) {
            XCTAssertNoDiff($0, expectedNavigation, "Expected \(expectedNavigation), but got \($0) instead.", file: file, line: line)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: timeout)
    }
}
