//
//  QRParameterTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 10.12.2024.
//

@testable import ForaBank
import XCTest

final class QRParameterTests: XCTestCase {
    
    func test_decoding_shouldLowercaseKeys() throws {
        
        let decoded = try decode(generalInnJSON)
        
        XCTAssertNoDiff(decoded.keys, ["payeeinn", "amount", "bic"])
        XCTAssertNoDiff(decoded.parameter, .general(.inn))
        XCTAssertNoDiff(decoded.type, .string)
    }
    
    func test_decoding_withEmptyKeys_shouldHandleGracefully() throws {
        
        let decoded = try decode(generalAmountEmptyKeysJSON)
        
        XCTAssertTrue(decoded.keys.isEmpty)
        XCTAssertNoDiff(decoded.parameter, .general(.amount))
        XCTAssertNoDiff(decoded.type, .double)
    }
    
    // MARK: - Helpers
    
    private func decode(
        _ string: String
    ) throws -> QRParameter {
        
        let jsonData = try XCTUnwrap(string.data(using: .utf8))
        return try JSONDecoder().decode(QRParameter.self, from: jsonData)
    }
    
    private let generalInnJSON = """
    {
        "parameter": "GENERAL_INN",
        "keys": ["PayeeInn", "AMOUNT", "BIC"],
        "type": "STRING"
    }
    """
    
    private let generalAmountEmptyKeysJSON = """
    {
        "parameter": "GENERAL_AMOUNT",
        "keys": [],
        "type": "DOUBLE"
    }
    """
}
