//
//  URL+appendingSerialTests.swift
//
//
//  Created by Igor Malyarov on 11.09.2024.
//

import ForaTools
import XCTest

final class URL_appendingSerialTests: XCTestCase {
    
    func test_appendingSerial_shouldNotChangeURLOnNilSerial() throws {
        
        try XCTAssertNoDiff(baseURL().appendingSerial(nil), baseURL())
    }
    
    func test_appendingSerial_shouldNotChangeURLOnEmptySerial() throws {
        
        try XCTAssertNoDiff(baseURL().appendingSerial(""), baseURL())
    }
    
    func test_appendingSerial_shouldAppendNonEmptySerial() throws {
        
        let serial = anyMessage()
        let url = try baseURL().appendingSerial(serial)
        
        XCTAssertNoDiff(url.absoluteString, "https://any-url?serial=\(serial)")
        XCTAssertFalse(serial.isEmpty)
    }
    
    // MARK: - helpers
    
    func baseURL() throws -> URL {
        
        try XCTUnwrap(URL(string: "https://any-url"))
    }
}
