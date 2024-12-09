//
//  Model+PaymentsTransferSFPAdditionalTests.swift
//  VortexTests
//
//  Created by Andryusina Nataly on 15.11.2023.
//

@testable import Vortex
import XCTest

final class Model_PaymentsTransferSFPAdditionalTests: XCTestCase {
    
    func test_paymentsTransferSFPAdditional_parameterValueEmpty_shouldReturnEmpty() throws {
        
        let sut = makeSUT()
        
        let result = try sut.paymentsTransferSFPAdditional(
            [paramEmptyValue],
            allParameters: [])
        
        XCTAssertNoDiff(result, [])
    }

    func test_paymentsTransferSFPAdditional_parameterValueNotEmpty_shouldReturnAdditionals() throws {
        
        let sut = makeSUT()
        
        let result = try sut.paymentsTransferSFPAdditional(
            [paramPhone, paramRecipient],
            allParameters: [paramSfpMessage])
        
        XCTAssertNoDiff(result, .additionals)
    }
    
    func test_paymentsTransferSFPAdditional_withoutMessage_shouldReturnAdditionalsWithoutMessage() throws {
        
        let sut = makeSUT()
        
        let result = try sut.paymentsTransferSFPAdditional(
            [paramPhone, paramRecipient],
            allParameters: [])
        
        XCTAssertNoDiff(result, .additionalsWithoutMessage)
    }
    
    // MARK: - Helpers
    
    let paramSfpMessage = Payments.ParameterMock(
        id: .sfpMessage,
        value: "message")
    
    let paramEmptyValue = Payments.Parameter(
        id: .phoneParameterId,
        value: nil)

    
    let paramPhone = Payments.Parameter(
        id: .phoneParameterId,
        value: "+7 963 000-00-00")
    
    let paramRecipient = Payments.Parameter(
        id: .recipientParameterId,
        value: "Иванов")
    
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
    static let recipientParameterId: Self = Payments.Parameter.Identifier.sftRecipient.rawValue
    static let sfpMessage: Self = Payments.Parameter.Identifier.sfpMessage.rawValue
}

private extension TransferAnywayData.Additional {
    
    static let recipientId: Self = .init(
        fieldid: 1,
        fieldname: "RecipientID",
        fieldvalue: "79630000000"
    )
    
    static let recipientNm: Self = .init(
        fieldid: 2,
        fieldname: "RecipientNm",
        fieldvalue: "Иванов"
    )

    static let message: Self = .init(
        fieldid: 3,
        fieldname: "Ustrd",
        fieldvalue: "message"
    )
}

private extension Array where Element == TransferAnywayData.Additional {
    
    static let additionals: Self = [
        .recipientId,
        .recipientNm,
        .message
    ]
    
    static let additionalsWithoutMessage: Self = [
        .recipientId,
        .recipientNm
    ]
}
