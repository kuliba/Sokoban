//
//  CreateInterestDepositTransferPayloadTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 20.04.2023.
//

import XCTest
@testable import ForaBank

final class CreateInterestDepositTransferPayloadTests: XCTestCase {
    
    let encoder = JSONEncoder.serverDate

    func test_amountRoundedFinance_10_04() throws {
        
        // given
        let sut = makeSut(amount: 10.04)
        let expectedResult = "{\"check\":false,\"amount\":10.04,\"depositId\":0}"
        
        // when
        let sutEncoded = try encoder.encode(sut)
        let result = String(data: sutEncoded, encoding: .utf8)
        
        // then
        XCTAssertEqual(result, expectedResult)
    }
    
    func test_amountRoundedFinance_181_8() throws {
        
        // given
        let sut = makeSut(amount: 181.8)
        let expectedResult = "{\"check\":false,\"amount\":181.8,\"depositId\":0}"
        
        // when
        let sutEncoded = try encoder.encode(sut)
        let result = String(data: sutEncoded, encoding: .utf8)
        
        // then
        XCTAssertEqual(result, expectedResult)
    }
    
    func test_amountRoundedFinance_54_08() throws {
        
        // given
        let sut = makeSut(amount: 54.08)
        let expectedResult = "{\"check\":false,\"amount\":54.08,\"depositId\":0}"
        
        // when
        let sutEncoded = try encoder.encode(sut)
        let result = String(data: sutEncoded, encoding: .utf8)
        
        // then
        XCTAssertEqual(result, expectedResult)
    }
}

private extension CreateInterestDepositTransferPayloadTests {
    
    func makeSut(amount: Double?) -> ServerCommands.TransferController.CreateInterestDepositTransfer.Payload {
        
        .init(
            check: false,
            amount: amount,
            currencyAmount: nil,
            payer: nil,
            comment: nil,
            depositId: 0)
    }
}
