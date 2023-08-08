//
//  PublicTransportKeyTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 02.08.2023.
//

import ForaBank
import XCTest

final class PublicTransportKeyTests: XCTestCase {
    
    func test_shouldExtractSecKeyFromPublicTransportKey() throws {
        
        XCTAssertNoThrow(try PublicTransportKeyDomain.fromCert())
    }
}
