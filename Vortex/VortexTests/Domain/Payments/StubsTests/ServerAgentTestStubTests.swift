//
//  ServerAgentTestStubTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 18.06.2023.
//

@testable import ForaBank
import XCTest

final class ServerAgentTestStubTests: XCTestCase {
    
    func test_executeCommand_shouldThrowOnStubbedError() async throws {
        
        let sut: ServerAgentProtocol = ServerAgentTestStub([
            .getPhoneInfo(.failure(.emptyResponse))
        ])
        let command = makeCreateAnywayTransfer()
        
        try await assertThrows(try await sut.executeCommand(command: command))
    }
    
    //    func test_executeCommand_shouldReturnStubbedResult_iFora_4285_10rub() async throws {
    //
    //        let sut: ServerAgentProtocol = ServerAgentTestStub([
    //            .anywayTransfer(.success(.iFora_4285_10rub))
    //        ])
    //        let command = makeCommand()
    //
    //        let result = try await sut.executeCommand(command: command)
    //
    //        XCTAssertNoDiff(result.additionalList.map(\.fieldTitle), [
    //            "Номер телефона (без +7):",
    //            "Сумма, руб.:",
    //        ])
    //    }
    
    //    func test_executeCommand_shouldReturnStubbedResult() async throws {
    //
    //        let data = makeTransferAnywayResponseData(finalStep: false, needSum: false)
    //        let response = makeCreateAnywayTransferResponse(data: data)
    //        let sut: ServerAgentProtocol = ServerAgentTestStub([
    //            .anywayTransfer(.success(response))
    //        ])
    //        let command = makeCreateAnywayTransfer()
    //
    //        let result = try await sut.executeCommand(command: command)
    //
    //        XCTAssertNoDiff(result.amount, 9.99)
    //    }
    
    // MARK: - Helpers
    
    typealias CreateAnywayTransfer = ServerCommands.TransferController.CreateAnywayTransfer
    
    private func makeCreateAnywayTransfer(
        token: String = "any token",
        puref: String? = "puref"
    ) -> CreateAnywayTransfer {
        
        .makeCreateAnywayTransfer(token: token, puref: puref)
    }
    
    private func makeTransferAnywayData(
        puref: String?
    ) -> TransferAnywayData {
        
        .makeTransferAnywayData(puref: puref)
    }
}

func anyNSError() -> NSError {
    
    .init(domain: "Any NSError", code: 0)
}

extension TransferData.Payer {
    
    static func test(
        inn: String? = nil,
        accountId: Int? = nil,
        accountNumber: String? = nil,
        cardId: Int? = nil,
        cardNumber: String? = nil,
        phoneNumber: String? = nil
    ) -> Self {
        
        .init(
            inn: inn,
            accountId: accountId,
            accountNumber: accountNumber,
            cardId: cardId,
            cardNumber: cardNumber,
            phoneNumber: phoneNumber
        )
    }
}

extension Array where Element == TransferAnywayData.Additional {
    
    static func test(count: UInt) -> Self {
        
        (0..<count).map { .test(fieldID: Int($0)) }
    }
}

extension TransferAnywayData.Additional {
    
    static func test(
        fieldID: Int,
        fieldName: String? = nil,
        fieldValue: String? = nil
    ) -> Self {
        
        .init(
            fieldid: fieldID,
            fieldname: fieldName ?? "Field Name \(fieldID)",
            fieldvalue: fieldValue ?? "Field Value \(fieldID)"
        )
    }
}

extension ServerCommands.TransferController.CreateAnywayTransfer {
    
    static func makeCreateAnywayTransfer(
        token: String = "any token",
        puref: String? = "puref",
        payload: TransferAnywayData = .makeTransferAnywayData(puref: "puref")
    ) -> Self {
        
        return .init(
            token: token,
            isNewPayment: true,
            payload: payload
        )
    }
}

extension TransferAnywayData {
    
    static func makeTransferAnywayData(
        puref: String?
    ) -> TransferAnywayData {
        
        .init(
            amount: Decimal?.none,
            check: true,
            comment: nil,
            currencyAmount: "RUB",
            payer: .test(),
            additional: .test(count: 2),
            puref: puref
        )
    }
}

extension TransferAnywayResponseData {
    
    static func makeTransferAnywayResponseData(
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
        documentStatus: TransferResponseBaseData.DocumentStatus? = nil,
        paymentOperationDetailId: Int = 1,
        additionalList: [TransferAnywayResponseData.AdditionalData] = [],
        finalStep: Bool,
        infoMessage: String? = nil,
        needSum: Bool,
        printFormType: String? = nil,
        parameterListForNextStep: [ParameterData] = [],
        scenario: AntiFraudScenario = .ok
    ) -> TransferAnywayResponseData {
        
        .init(
            amount: amount,
            creditAmount: creditAmount,
            currencyAmount: currencyAmount,
            currencyPayee: currencyPayee,
            currencyPayer: currencyPayer,
            currencyRate: currencyRate,
            debitAmount: debitAmount,
            fee: fee,
            needMake: needMake,
            needOTP: needOTP,
            payeeName: payeeName,
            documentStatus: documentStatus,
            paymentOperationDetailId: paymentOperationDetailId,
            additionalList: additionalList,
            finalStep: finalStep,
            infoMessage: infoMessage,
            needSum: needSum,
            printFormType: printFormType,
            parameterListForNextStep: parameterListForNextStep,
            scenario: scenario
        )
    }
}
