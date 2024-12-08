//
//  ServerAgentStubHelpersTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 24.02.2023.
//

@testable import ForaBank
import XCTest

final class ServerAgentStubHelpersTests: XCTestCase {
    
    // MARK: - test essenceStub
    
    func test_iVortex_4285_9rub_shouldHaveDifferentPhoneNumbers() {
        
        XCTAssertNotEqual(
            ServerAgentStub.Essence.iVortex_4285_9rub.phoneNumber,
            ServerAgentStub.AnywayTransferResponse.iVortex_4285_9rub.phoneNumber,
            "Expected to have nil data field for error case."
        )
    }

    func test_iVortex_4285_10rub_shouldHaveMatchingPhoneNumbers() {
        
        XCTAssertEqual(
            ServerAgentStub.Essence.iVortex_4285_10rub.phoneNumber,
            ServerAgentStub.AnywayTransferResponse.iVortex_4285_10rub.phoneNumber
        )
    }

    func test_iVortex_4286_shouldHaveMatchingPhoneNumbers() {
        
        XCTAssertEqual(
            ServerAgentStub.Essence.iVortex_4286.phoneNumber,
            ServerAgentStub.AnywayTransferResponse.iVortex_4286.phoneNumber
        )
    }

    func test_iVortex_515A3_1rub_shouldHaveDifferentPhoneNumbers() {
        
        XCTAssertNotEqual(
            ServerAgentStub.Essence.iVortex_515A3_1rub.phoneNumber,
            ServerAgentStub.AnywayTransferResponse.iVortex_515A3_1rub.phoneNumber,
            "Expected to have nil data field for error case."
        )
    }

    func test_iVortex_515A3_10rub_shouldHaveMatchingPhoneNumbers() {
        
        XCTAssertEqual(
            ServerAgentStub.Essence.iVortex_515A3_10rub.phoneNumber,
            ServerAgentStub.AnywayTransferResponse.iVortex_515A3_10rub.phoneNumber
        )
    }

}
