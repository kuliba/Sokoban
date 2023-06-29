//
//  Model+PaymentsAbroadTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 30.05.2023.
//

import XCTest
@testable import ForaBank

final class Model_PaymentsAbroadTests: XCTestCase {

    func test_paymentsTransferAbroadStepParameter_emptyResult() async throws {
        
        // given
        let sut = makeSut()
        
        // when
        let operation = Payments.Operation.makeEmpty()
        let response = TransferAnywayResponseData.make()
        let result = try await sut.paymentsTransferAbroadStepParameters(operation, response: response)
        
        // then
        XCTAssertTrue(result.isEmpty)
    }
}

private extension Model_PaymentsAbroadTests {
    
    func makeSut() -> Model {
        
        .emptyMock
    }
}

private extension Payments.Operation {
    
    static func makeEmpty() -> Payments.Operation {
        
        .init(service: .abroad)
    }
}

private extension TransferAnywayResponseData {
    
    static func make(
        amount: Double? = nil,
        creditAmount: Double? = nil,
        currencyAmount: Currency? = nil,
        currencyPayee: Currency? = nil,
        currencyPayer: Currency? = nil,
        currencyRate: Double? = nil,
        debitAmount: Double? = nil,
        fee: Double? = nil,
        needMake: Bool? = nil,
        needOTP: Bool? = nil,
        payeeName: String? = nil,
        documentStatus: DocumentStatus? = nil,
        paymentOperationDetailId: Int = 0,
        additionalList: [AdditionalData] = [],
        finalStep: Bool = false,
        infoMessage: String? = nil,
        needSum: Bool = false,
        printFormType: String? = nil,
        parameterListForNextStep: [ParameterData] = []) -> TransferAnywayResponseData {
            
            .init(amount: amount, creditAmount: creditAmount, currencyAmount: currencyAmount, currencyPayee: currencyPayee, currencyPayer: currencyPayer, currencyRate: currencyRate, debitAmount: debitAmount, fee: fee, needMake: needMake, needOTP: needOTP, payeeName: payeeName, documentStatus: documentStatus, paymentOperationDetailId: paymentOperationDetailId, additionalList: additionalList, finalStep: finalStep, infoMessage: infoMessage, needSum: needSum, printFormType: printFormType, parameterListForNextStep: parameterListForNextStep)
        }
}
