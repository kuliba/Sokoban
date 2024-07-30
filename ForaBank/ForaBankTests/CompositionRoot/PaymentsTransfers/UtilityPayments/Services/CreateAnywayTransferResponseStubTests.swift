//
//  CreateAnywayTransferResponseStubTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 30.07.2024.
//

import AnywayPaymentDomain
import AnywayPaymentAdapters
@testable import ForaBank
import RemoteServices
import XCTest

final class CreateAnywayTransferResponseStubTests: XCTestCase {
    
    func test_step4_shouldMapToAnywayPaymentUpdate() {
        
        let update = AnywayPaymentUpdate(step4)
        XCTAssertNotNil(update)
    }

    func test_step4Fraud_shouldMapToAnywayPaymentUpdate() {
        
        let update = AnywayPaymentUpdate(step4Fraud)
        XCTAssertNotNil(update)
    }

    // MARK: - Helpers
    
    private let step4 = RemoteServices.ResponseMapper.CreateAnywayTransferResponse.step4
    private let step4Fraud = RemoteServices.ResponseMapper.CreateAnywayTransferResponse.step4Fraud
}
