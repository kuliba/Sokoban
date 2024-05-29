//
//  TransactionReducer_anywayTests.swift
//
//
//  Created by Igor Malyarov on 21.05.2024.
//

import AnywayPaymentCore
import AnywayPaymentDomain
import XCTest

final class TransactionReducer_anywayTests: XCTestCase {
    
    // TODO: add integration tests
    
    // MARK: - Helpers
    
    private typealias SUT = TransactionReducer<Report, AnywayPaymentContext, AnywayPaymentEvent, AnywayPaymentEffect, AnywayPaymentDigest, AnywayPaymentUpdate>
    private typealias Report = String
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT.anyway()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}
