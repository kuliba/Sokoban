//
//  TransferDataTests.swift
//  VortexTests
//
//  Created by Max Gribov on 20.04.2023.
//

import XCTest
@testable import Vortex

final class TransferDataTests: XCTestCase {

    let encoder = JSONEncoder.serverDate

    func test_amountRoundedFinance() throws {
        
        let amountDouble: Double = 10.04
        let amountDecimal = Decimal(amountDouble)
        let sut = makeSUT(amount: amountDecimal.roundedFinance())
        
        let encoded = try encoder.encode(sut)
        
        try XCTAssertNoDiff(encoded.jsonDict(), [
            "amount": 10.04,
            "check": false,
            "comment": NSNull(),
            "currencyAmount": "",
            "payer": [:]
        ])
    }
}

private extension TransferDataTests {
    
    func makeSUT(amount: Decimal?) -> TransferData {
        
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
