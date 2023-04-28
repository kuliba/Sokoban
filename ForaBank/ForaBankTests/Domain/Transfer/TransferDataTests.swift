//
//  TransferDataTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 20.04.2023.
//

import XCTest
@testable import ForaBank

final class TransferDataTests: XCTestCase {

    let encoder = JSONEncoder.serverDate

    func test_amountRoundedFinance() throws {
        
        // given
        let amountDouble: Double = 10.04
        let amountDecimal = Decimal(amountDouble)
        let sut = makeSut(amount: amountDecimal.roundedFinance())
        let expectedResult = "{\"amount\":10.04,\"check\":false,\"comment\":null,\"currencyAmount\":\"\",\"payer\":{}}"
        
        // when
        let sutEncoded = try encoder.encode(sut)
        let result = String(data: sutEncoded, encoding: .utf8)
        
        // then
        XCTAssertEqual(result, expectedResult)
    }
}

private extension TransferDataTests {
    
    func makeSut(amount: Decimal?) -> TransferData {
        
        .init(
            amount: amount,
            check: false,
            comment: nil,
            currencyAmount: "",
            payer: .init(
                inn: nil,
                accountId: nil,
                accountNumber: nil,
                cardId: nil,
                cardNumber: nil,
                phoneNumber: nil))
    }
}
