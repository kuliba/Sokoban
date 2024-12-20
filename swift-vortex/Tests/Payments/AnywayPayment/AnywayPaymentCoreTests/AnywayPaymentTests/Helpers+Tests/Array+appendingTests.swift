//
//  Array+appendingTests.swift
//
//
//  Created by Igor Malyarov on 05.04.2024.
//

import XCTest

final class Array_appendingTests: XCTestCase {
    
    func test_shouldDeliverArrayOfElementOnAppendingToEmpty() {
        
        XCTAssertNoDiff([].appending("eva"), ["eva"])
    }
    
    func test_shouldAppendToEndOnOneElement() {
        
        XCTAssertNoDiff(["john"].appending("eva"), ["john", "eva"])
    }
    
    func test_shouldAppendToEndOnTwoElements() {
        
        XCTAssertNoDiff(["paul", "john"].appending("eva"), ["paul", "john", "eva"])
    }
    
    func test_shouldAppendNilInOptionalArray() {
        
        let array: [String?] = ["john", nil, "paul"]

        XCTAssertNoDiff(array.appending(nil), ["john", nil, "paul", nil])
    }

    func test_shouldDeliverEmptyArrayOnAppendingEmptyToEmpty() {
        
        XCTAssertNoDiff([String]().appending(contentsOf: []), [])
    }
    
    func test_shouldDeliverSameArrayOnAppendingEmpty() {
        
        let array = ["paul", "john"]
        
        XCTAssertNoDiff(array.appending(contentsOf: []), array)
    }
    
    func test_shouldDeliverArrayOfOneElementOnAppendingToEmpty() {
        
        XCTAssertNoDiff([].appending(contentsOf: ["eva"]), ["eva"])
    }
    
    func test_shouldDeliverArrayOfTwoElementOnAppendingToEmpty() {
        
        XCTAssertNoDiff([].appending(contentsOf: ["paul", "john"]), ["paul", "john"])
    }
    
    func test_shouldAppendElementsToEndOnOneElement() {
        
        XCTAssertNoDiff(["john"].appending(contentsOf: ["paul", "eva"]), ["john", "paul", "eva"])
    }
    
    func test_shouldAppendElementsToEndOnTwoElements() {
        
        XCTAssertNoDiff(["john", "paul"].appending(contentsOf: ["mary", "eva"]), ["john", "paul", "mary", "eva"])
    }
}
