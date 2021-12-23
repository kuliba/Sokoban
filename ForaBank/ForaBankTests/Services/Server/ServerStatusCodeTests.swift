//
//  ServerStatusCodeTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 21.12.2021.
//

import XCTest
@testable import ForaBank

class ServerStatusCodeTests: XCTestCase {
    
    let decoder = JSONDecoder()

    func testOk() throws {
        
        // given
        let statusCode = "0".data(using: .utf8)!
        
        // when
        let result = try decoder.decode(ServerStatusCode.self, from: statusCode)
        
        // then
        XCTAssertEqual(result, .ok)
    }
    
    func testError() throws {
        
        // given
        let statusCode = "1".data(using: .utf8)!
        
        // when
        let result = try decoder.decode(ServerStatusCode.self, from: statusCode)
        
        // then
        XCTAssertEqual(result, .error(1))
    }
    
    func testUserNotAuthorized() throws {
        
        // given
        let statusCode = "101".data(using: .utf8)!
        
        // when
        let result = try decoder.decode(ServerStatusCode.self, from: statusCode)
        
        // then
        XCTAssertEqual(result, .userNotAuthorized)
    }
    
    func testServerError() throws {
        
        // given
        let statusCode = "102".data(using: .utf8)!
        
        // when
        let result = try decoder.decode(ServerStatusCode.self, from: statusCode)
        
        // then
        XCTAssertEqual(result, .serverError)
    }
    
    func testIncorrectRequest() throws {
        
        // given
        let statusCode = "400".data(using: .utf8)!
        
        // when
        let result = try decoder.decode(ServerStatusCode.self, from: statusCode)
        
        // then
        XCTAssertEqual(result, .incorrectRequest)
    }
    
    func testUnknownRequest() throws {
        
        // given
        let statusCode = "404".data(using: .utf8)!
        
        // when
        let result = try decoder.decode(ServerStatusCode.self, from: statusCode)
        
        // then
        XCTAssertEqual(result, .unknownRequest)
    }

    func testUnknownStatus() throws {
        
        // given
        let statusCode = "46".data(using: .utf8)!
        
        // when
        let result = try decoder.decode(ServerStatusCode.self, from: statusCode)
        
        // then
        XCTAssertEqual(result, .unknownStatus)
    }
}
