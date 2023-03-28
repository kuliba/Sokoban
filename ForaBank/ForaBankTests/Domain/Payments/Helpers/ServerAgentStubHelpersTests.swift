//
//  ServerAgentStubHelpersTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 24.02.2023.
//

@testable import ForaBank
import XCTest

final class ServerAgentStubHelpersTests: XCTestCase {
    
    func test_essenceStub_shouldHaveMatchingFields() {
        
        // MARK: - iFora_4285_9rub
        
        XCTAssertNotEqual(
            ServerAgentStub.Essence.iFora_4285_9rub.phoneNumber,
            ServerAgentStub.AnywayTransferResponse.iFora_4285_9rub.phoneNumber,
            "Expected to have nil data field for error case."
        )
        
        // MARK: - iFora_4285_10rub
        
        XCTAssertEqual(
            ServerAgentStub.Essence.iFora_4285_10rub.phoneNumber,
            ServerAgentStub.AnywayTransferResponse.iFora_4285_10rub.phoneNumber
        )
        
        // MARK: - iFora_4286
        
        XCTAssertEqual(
            ServerAgentStub.Essence.iFora_4286.phoneNumber,
            ServerAgentStub.AnywayTransferResponse.iFora_4286.phoneNumber
        )
        
        // MARK: - iFora_515A3_1rub
        
        XCTAssertNotEqual(
            ServerAgentStub.Essence.iFora_515A3_1rub.phoneNumber,
            ServerAgentStub.AnywayTransferResponse.iFora_515A3_1rub.phoneNumber,
            "Expected to have nil data field for error case."
        )
        
        // MARK: - iFora_515A3_10rub
        
        XCTAssertEqual(
            ServerAgentStub.Essence.iFora_515A3_10rub.phoneNumber,
            ServerAgentStub.AnywayTransferResponse.iFora_515A3_10rub.phoneNumber
        )
    }
}
