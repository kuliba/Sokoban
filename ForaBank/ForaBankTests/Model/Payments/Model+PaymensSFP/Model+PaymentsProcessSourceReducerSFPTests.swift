//
//  Model+PaymentsProcessSourceReducerSFPTests.swift
//  ForaBankTests
//
//  Created by Andryusina Nataly on 16.11.2023.
//

@testable import ForaBank
import XCTest

final class Model_PaymentsProcessSourceReducerSFPTests: XCTestCase {
    
    func test_paymentsProcessSourceReducerSFP_parameterNotBankNotPhone_shouldReturnNil() {
        
        let sut = makeSUT()
        
        let result = sut.paymentsProcessSourceReducerSFP(
            phone: "9630000000",
            bankId: "1111",
            amount: nil,
            parameterId: Payments.Parameter.Identifier.sfpMessage.rawValue
        )
        
        XCTAssertNoDiff(result, nil)
    }

    func test_paymentsProcessSourceReducerSFP_parameterPhone10Digits_shouldReturnPhone() {
        
        let sut = makeSUT()
        
        let result = sut.paymentsProcessSourceReducerSFP(
            phone: "9630000000",
            bankId: "1111", 
            amount: nil,
            parameterId: .phoneParameterId
        )
        
        XCTAssertNoDiff(result, "+7 963 000-00-00")
    }
    
    func test_paymentsProcessSourceReducerSFP_parameterPhoneLess10Digits_shouldReturnPhone() {
        
        let sut = makeSUT()
        
        let result = sut.paymentsProcessSourceReducerSFP(
            phone: "963000000",
            bankId: "1111", 
            amount: nil,
            parameterId: .phoneParameterId
        )
        
        XCTAssertNoDiff(result, "+963 000 000")
    }

    func test_paymentsProcessSourceReducerSFP_parameterPhoneMore10Digits_shouldReturnPhone() {
        
        let sut = makeSUT()
        
        let result = sut.paymentsProcessSourceReducerSFP(
            phone: "96300000000",
            bankId: "1111",
            amount: nil,
            parameterId: .phoneParameterId
        )
        
        XCTAssertNoDiff(result, "+963 000 000 00")
    }

    func test_paymentsProcessSourceReducerSFP_parameterBank_shouldReturnBank() {
        
        let sut = makeSUT()
        
        let result = sut.paymentsProcessSourceReducerSFP(
            phone: "9630000000",
            bankId: "1111",
            amount: nil,
            parameterId: .bankId
        )
        
        XCTAssertNoDiff(result, "1111")
    }

    // MARK: - Helpers

    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> Model {
        
        let sut: Model = .mockWithEmptyExcept()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}

private extension String {
    
    static let phoneParameterId: Self = Payments.Parameter.Identifier.sfpPhone.rawValue
    static let bankId: Self = Payments.Parameter.Identifier.sfpBank.rawValue
}
