//
//  Dummy.swift
//
//
//  Created by Valentin Ozerov on 13.11.2024.
//

// TODO: Will be delete after tests creation

import XCTest

final class DummyTest: XCTest {
    
    func test_test() {
        
        XCTAssertTrue(true)
    }
    
    func test_fail() {
        
        fatalError()
        XCTFail()
    }
}
