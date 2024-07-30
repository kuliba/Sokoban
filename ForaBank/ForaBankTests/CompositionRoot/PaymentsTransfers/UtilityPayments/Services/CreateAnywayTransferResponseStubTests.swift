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
    
    func test_shouldMapToAnywayPaymentUpdate() {
        
        let update = AnywayPaymentUpdate(stub)
        XCTAssertNotNil(update)
    }

    // MARK: - Helpers
    
    private let stub = RemoteServices.ResponseMapper.CreateAnywayTransferResponse.step4
}
