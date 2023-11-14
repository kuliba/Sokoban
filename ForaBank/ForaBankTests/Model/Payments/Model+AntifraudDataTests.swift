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
        
        let operation = operation(parameters: [paramSfpAntifraudG])
        
        let sut: Model = .mockWithEmptyExcept()
        
        let result = sut.paymentsAntifraudData(for: operation)
        
        XCTAssertNil(result)
    }
    
    func test_paymentsAntifraudData_serviceSfp_sfpAntifraudValueNotGWithoutAmount_shouldReturnNil() {
        
        let operation = operation(parameters: [paramSfpAntifraud, paramPhone, paramRecipient])
        
        let sut: Model = .mockWithEmptyExcept()
        
        let result = sut.paymentsAntifraudData(for: operation)
        
        XCTAssertNil(result)
    }
    
    func test_paymentsAntifraudData_serviceSfp_sfpAntifraudValueNotGWithoutPhone_shouldReturnNil() {
        
        let operation = operation(parameters: [paramSfpAntifraud, paramAmount, paramPhone])
        
        let sut: Model = .mockWithEmptyExcept()
        
        let result = sut.paymentsAntifraudData(for: operation)
        
        XCTAssertNil(result)
    }
    
    func test_paymentsAntifraudData_serviceSfp_sfpAntifraudValueNotGWithoutRecipient_shouldReturnNil() {
        
        let operation = operation(parameters: [paramSfpAntifraud, paramAmount, paramRecipient])
        
        let sut: Model = .mockWithEmptyExcept()
        
        let result = sut.paymentsAntifraudData(for: operation)
        
        XCTAssertNil(result)
    }
    
    func test_paymentsAntifraudData_serviceSfp_sfpAntifraudValueNotGWithAllParameters_shouldReturnData() {
        
        let operation = operation(parameters: [paramSfpAntifraud, paramAmount, paramPhone, paramRecipient])
        
        let sut: Model = .mockWithEmptyExcept()
        
        let result = sut.paymentsAntifraudData(for: operation)
        
        let antifraudData: Payments.AntifraudData? = .init(
            payeeName: "Иванов",
            phone: "+7 963 000-00-00",
            amount: "- 1231 P")
        
        XCTAssertNoDiff(result?.equatable, antifraudData?.equatable)
    }
    
    // MARK: - Helpers
    
    let paramSfpAntifraud = Payments.ParameterMock(
        id: .sfpAntifraudId,
        value: "G1")
    
    let paramSfpAntifraudG = Payments.ParameterMock(
        id: .sfpAntifraudId,
        value: "G")
    
    let paramAmount = Payments.ParameterMock(
        id: .amountParameterId,
        value: "1231 P")
    
    let paramPhone = Payments.ParameterMock(
        id: .phoneParameterId,
        value: "79630000000")
    
    let paramRecipient = Payments.ParameterMock(
        id: .recipientParameterId,
        value: "Иванов")
    
    func operation(
        service: Payments.Service = .sfp,
        parameters: [any PaymentsParameterRepresentable]
    ) -> Payments.Operation {
        
        let stepOne = Payments.Operation.Step(
            parameters: parameters,
            front: .empty(),
            back: .empty())
        
        return .init(
            service: service,
            source: nil,
            steps: [stepOne],
            visible: [])
    }
}

private extension String {
    
    static let amountParameterId: Self = Payments.Parameter.Identifier.sfpAmount.rawValue
    static let phoneParameterId: Self = Payments.Parameter.Identifier.sfpPhone.rawValue
    static let recipientParameterId: Self = Payments.Parameter.Identifier.sftRecipient.rawValue
    static let sfpAntifraudId: Self = Payments.Parameter.Identifier.sfpAntifraud.rawValue
}

private extension Payments {
    
    struct EquatableAntifraudData: Equatable {
        
        let payeeName: String
        let phone: String
        let amount: String
    }
}

private extension Payments.AntifraudData {
    
    var equatable: Payments.EquatableAntifraudData {
        .init(
            payeeName: self.payeeName,
            phone: self.phone,
            amount: self.amount)
    }
}
