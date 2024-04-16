//
//  MicroServices+FastPaymentsSettingsGetSettingsTests.swift
//
//
//  Created by Igor Malyarov on 15.02.2024.
//

import FastPaymentsSettings
import XCTest

final class MicroServices_FastPaymentsSettingsGetSettingsTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, getContractSpy, getConsentSpy, getBankDefaultSpy) = makeSUT()
        
        XCTAssertEqual(getContractSpy.callCount, 0)
        XCTAssertEqual(getConsentSpy.callCount, 0)
        XCTAssertEqual(getBankDefaultSpy.callCount, 0)
    }
    
    func test_process_shouldDeliverMissingContractOnNilContractNilConsent_a3b3c1() {
        
        let (sut, getContractSpy, getConsentSpy, getBankDefaultSpy) = makeSUT()
        
        expect(sut, toDeliver: .success(.missingContract(.failure(.collapsedError))), on: {
            
            getContractSpy.complete(with: .success(nil)) // a3
            getConsentSpy.complete(with: nil)            // b3
        })
        
        XCTAssertEqual(getBankDefaultSpy.callCount, 0)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = MicroServices.SettingsGetter<UserPaymentSettings.PaymentContract, Consent?, UserPaymentSettings>
    
    private typealias GetContractSpy = Spy<Void, SUT.GetContractResult>
    private typealias GetConsentSpy = Spy<Void, Consent?>
    private typealias GetBankDefaultSpy = Spy<PhoneNumber, UserPaymentSettings.GetBankDefaultResponse>
    
    private func makeSUT(
        getProductsStub: [Product] = [],
        getBanksStub: [Bank] = [],
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        getContractSpy: GetContractSpy,
        getConsentSpy: GetConsentSpy,
        getBankDefaultSpy: GetBankDefaultSpy
    ) {
        
        let getContractSpy = GetContractSpy()
        let getConsentSpy = GetConsentSpy()
        let getBankDefaultSpy = GetBankDefaultSpy()
        
        let sut = SUT(
            getContract: getContractSpy.process(completion:),
            getConsent: getConsentSpy.process(completion:),
            getBankDefault: getBankDefaultSpy.process(_:completion:),
            getProducts: { getProductsStub },
            getBanks: { getBanksStub }
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(getContractSpy, file: file, line: line)
        trackForMemoryLeaks(getConsentSpy, file: file, line: line)
        trackForMemoryLeaks(getBankDefaultSpy, file: file, line: line)
        
        return (sut, getContractSpy, getConsentSpy, getBankDefaultSpy)
    }
    
    private func expect(
        _ sut: SUT,
        toDeliver expected: SUT.ProcessResult,
        on action: @escaping () -> Void,
        timeout: TimeInterval = 0.05,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.process {
            
            XCTAssertNoDiff($0, expected, "\nExpected \(expected), but got \($0) instead.", file: file, line: line)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: timeout)
    }
}
