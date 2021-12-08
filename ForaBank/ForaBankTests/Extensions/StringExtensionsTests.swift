//
//  StringExtensionsTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 07.12.2021.
//

import XCTest
@testable import ForaBank

class StringExtensionsTests: XCTestCase {

    func testContained_True() throws {

        // given
        let value = "test"
        let list = ["test", "data"]
        
        // when
        let result = value.contained(in: list)
        
        //then
        XCTAssertTrue(result)
    }
    
    func testContained_False() throws {

        // given
        let value = "test"
        let list = ["data", "other"]
        
        // when
        let result = value.contained(in: list)
        
        //then
        XCTAssertFalse(result)
    }
}
