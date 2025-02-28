//
//  CreateInterestDepositTransferPayloadTests.swift
//  VortexTests
//
//  Created by Max Gribov on 20.04.2023.
//

import XCTest
@testable import Vortex

final class CreateInterestDepositTransferPayloadTests: XCTestCase {
    
    let encoder = JSONEncoder.serverDate
    
    func test_amountRoundedFinance_10_04() throws {
        
        try assert(withAmount: 10.04, [
            "check": false,
            "amount": 10.04,
            "depositId": 0
        ])
    }
    
    func test_amountRoundedFinance_181_8() throws {
        
        try assert(withAmount: 181.8, [
            "check": false,
            "amount": 181.8,
            "depositId": 0
        ])
    }
    
    func test_amountRoundedFinance_54_08() throws {
        
        try assert(withAmount: 54.08, [
            "check": false,
            "amount": 54.08,
            "depositId": 0
        ])
    }
    
    // MARK: - Helpers
    
    func makeSUT(
        amount: Double?
    ) -> ServerCommands.TransferController.CreateInterestDepositTransfer.Payload {
        
        .init(
            check: false,
            amount: amount,
            currencyAmount: nil,
            payer: nil,
            comment: nil,
            depositId: 0)
    }
    
    private func assert(
        withAmount amount: Double?,
        _ expectedResult: NSDictionary,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        let sut = makeSUT(amount: amount)
        
        let encoded = try encoder.encode(sut)
        let result = try encoded.jsonDict(file: file, line: line)
        
        XCTAssertNoDiff(result as NSDictionary, expectedResult, file: file, line: line)
    }
}
