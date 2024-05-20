//
//  MultiElementArrayTest.swift
//
//
//  Created by Igor Malyarov on 26.04.2024.
//

import ForaTools
import XCTest

final class MultiElementArrayTest: XCTestCase {
    
    func test_init_shouldFailForEmpty() {
        
        let elements = [String]()
        
        XCTAssertNil(MultiElementArray(elements))
    }
    
    func test_init_shouldFailForOne() {
        
        let elements = ["a"]
        
        XCTAssertNil(MultiElementArray(elements))
    }
    
    func test_init_shouldNotFailForTwo() {
        
        let elements = ["a", "b"]
        
        XCTAssertNotNil(MultiElementArray(elements))
    }
    
    func test_init_shouldNotFailForThree() {
        
        let elements = ["a", "b", "c"]
        
        XCTAssertNotNil(MultiElementArray(elements))
    }
    
    func test_init_shouldNotFailForFive() {
        
        let elements = ["a", "b", "c", "d", "e"]
        
        XCTAssertNotNil(MultiElementArray(elements))
    }
    
    func test_elements_shouldDeliverElementsForTwo() {
        
        let elements = ["a", "b"]
        
        XCTAssertNoDiff(MultiElementArray(elements)?.elements, elements)
    }
    
    func test_elements_shouldDeliverElementsForThree() {
        
        let elements = ["a", "b", "c"]
        
        XCTAssertNoDiff(MultiElementArray(elements)?.elements, elements)
    }
    
    func test_elements_shouldDeliverElementsForFive() {
        
        let elements = ["a", "b", "c"]
        
        XCTAssertNoDiff(MultiElementArray(elements)?.elements, elements)
    }
}
