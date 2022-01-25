//
//  URLHostTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 20.12.2021.
//

import XCTest
@testable import ForaBank

class URLHostTests: XCTestCase {

    func testGetHost() throws {

        let host = URLHost().getHost()
        
        #if DEBUG
        XCTAssertEqual(host, "git.briginvest.ru/dbo/api/v3")
        #else
        XCTAssertEqual(host, "bg.forabank.ru/dbo/api/v4/f437e29a3a094bcfa73cea12366de95b")
        #endif
    }
}
