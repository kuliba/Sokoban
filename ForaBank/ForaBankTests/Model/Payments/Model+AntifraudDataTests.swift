//
//  Model+AntifraudDataTests.swift
//  ForaBankTests
//
//  Created by Andryusina Nataly on 14.11.2023.
//

@testable import ForaBank
import XCTest

final class Model_AntifraudDataTests: XCTestCase {
    
    // MARK: - paymentsAntifraudData

    func test_paymentsAntifraudData_serviceNotSfp_shouldReturnNil() {
        
        let operation: Payments.Operation = .init(service: .avtodor)

        let sut: Model = .mockWithEmptyExcept()
        
        let result = sut.paymentsAntifraudData(for: operation)
        
        XCTAssertNil(result)
    }
    
    func test_paymentsAntifraudData_serviceSfp_sfpAntifraudNil_shouldReturnNil() {
        
        let operation: Payments.Operation = .init(service: .sfp)

        let sut: Model = .mockWithEmptyExcept()
        
        let result = sut.paymentsAntifraudData(for: operation)
        
        XCTAssertNil(result)
    }  
    
    func test_paymentsAntifraudData_serviceSfp_sfpAntifraudValueG_shouldReturnNil() {
        
        let paramOne = Payments.ParameterMock(
            id: .sfpAntifraudId,
            value: "G")
        let stepOne = Payments.Operation.Step(
            parameters: [paramOne],
            front: .empty(),
            back: .empty())

        let operation: Payments.Operation = .init(
            service: .sfp,
            source: nil,
            steps: [stepOne],
            visible: [])

        let sut: Model = .mockWithEmptyExcept()
        
        let result = sut.paymentsAntifraudData(for: operation)
        
        XCTAssertNil(result)
    }
}

private extension String {
    
    static let amountParameterId: Self = Payments.Parameter.Identifier.sfpAmount.rawValue
    static let phoneParameterId: Self = Payments.Parameter.Identifier.sfpPhone.rawValue
    static let recipientParameterId: Self = Payments.Parameter.Identifier.sftRecipient.rawValue
    static let sfpAntifraudId: Self = Payments.Parameter.Identifier.sfpAntifraud.rawValue
}
