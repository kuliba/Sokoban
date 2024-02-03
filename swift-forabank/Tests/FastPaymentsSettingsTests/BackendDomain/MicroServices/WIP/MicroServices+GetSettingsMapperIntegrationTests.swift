//
//  MicroServices+GetSettingsMapperIntegrationTests.swift
//
//
//  Created by Igor Malyarov on 26.01.2024.
//

import FastPaymentsSettings
import XCTest

final class MicroServices_GetSettingsMapperIntegrationTests: XCTestCase {
    
    func test_init_shouldNotCallCollaboratorsOnEmptyProducts() {
        
        let (_, getContractSpy, getConsentSpy, getBankDefaultSpy) = makeSUT(products: [])
        
        XCTAssertEqual(getContractSpy.callCount, 0)
        XCTAssertEqual(getConsentSpy.callCount, 0)
        XCTAssertEqual(getBankDefaultSpy.callCount, 0)
    }
    
    func test_init_shouldNotCallCollaboratorsOnOneProduct() {
        
        let (_, getContractSpy, getConsentSpy, getBankDefaultSpy) = makeSUT(
            products: [makeProduct()]
        )
        
        XCTAssertEqual(getContractSpy.callCount, 0)
        XCTAssertEqual(getConsentSpy.callCount, 0)
        XCTAssertEqual(getBankDefaultSpy.callCount, 0)
    }
    
    func test_init_shouldNotCallCollaboratorsOnManyProducts() {
        
        let (_, getContractSpy, getConsentSpy, getBankDefaultSpy) = makeSUT(
            products: [makeProduct(), makeProduct()]
        )
        
        XCTAssertEqual(getContractSpy.callCount, 0)
        XCTAssertEqual(getConsentSpy.callCount, 0)
        XCTAssertEqual(getBankDefaultSpy.callCount, 0)
    }
    
//    func test_process___() {
//        
//        let products = [makeProduct(), makeProduct()]
//        let (sut, getContractSpy, getConsentSpy, getBankDefaultSpy) = makeSUT(products: products)
//        
//        expect(
//            sut,
//            toDeliver: .success(.contracted(.init(
//                paymentContract: <#T##UserPaymentSettings.PaymentContract#>,
//                consentList: <#T##ConsentListState#>,
//                bankDefaultResponse: <#T##UserPaymentSettings.GetBankDefaultResponse#>,
//                productSelector: <#T##UserPaymentSettings.ProductSelector#>
//            ))),
//            on: {
//                
//            }
//        )
//    }
    
    // MARK: - Helpers
    
    private typealias SUT = MicroServices.SettingsGetter<UserPaymentSettings.PaymentContract, Consent?, UserPaymentSettings>
    
    private typealias GetContractSpy = Spy<Void, SUT.GetContractResult>
    private typealias GetConsentSpy = Spy<Void, Consent>
    private typealias GetBankDefaultSpy = Spy<PhoneNumber, UserPaymentSettings.GetBankDefaultResponse>
    
    private func makeSUT(
        products: [Product],
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
            getProducts: { products },
            getBanks: { [] }
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
    
    private func anyPhoneNumber(
        _ value: String = anyMessage()
    ) -> PhoneNumber {
        
        .init(value)
    }
}
