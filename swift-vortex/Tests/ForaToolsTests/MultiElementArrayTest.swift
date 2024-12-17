//
//  MultiElementArrayTest.swift
//
//
//  Created by Igor Malyarov on 26.04.2024.
//

import ForaTools
import XCTest

final class MultiElementArrayTest: XCTestCase {
    
    // MARK: - init
    
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
    
    func test_init_emptyTail() {
        
        let multi = MultiElementArray("a", "b", [])
        
        XCTAssertNoDiff(multi.elements, ["a", "b"])
    }
    
    func test_init_nonTailOfOne() {
        
        let multi = MultiElementArray("a", "b", ["c"])

        XCTAssertNoDiff(multi.elements, ["a", "b", "c"])
    }
    
    func test_init_nonTailOfTwo() {
        
        let multi = MultiElementArray("a", "b", ["c", "d"])

        XCTAssertNoDiff(multi.elements, ["a", "b", "c", "d"])
    }
    
    // MARK: - elements
    
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
    
    // MARK: - append
    
    func test_append() throws {
        
        var multi = try XCTUnwrap(MultiElementArray(["a", "b"]))
        
        multi.append("1")
        
        XCTAssertNoDiff(multi.elements, ["a", "b", "1"])
    }
    
    // MARK: - insert

    func test_insert() throws {
        
        var multi = try XCTUnwrap(MultiElementArray(["a", "b"]))
        
        multi.insert("1")
        
        XCTAssertNoDiff(multi.elements, ["1", "a", "b"])
    }
    
    // MARK: - map

    func test_map() {
        
        let multi = MultiElementArray(1, 2)
        
        XCTAssertNoDiff(multi.map({ "\($0)" }).elements, ["1", "2"])
    }
    
    // MARK: - concatenate

    func test_concatenate() {
        
        let lhs = MultiElementArray(1, 2)
        let rhs = MultiElementArray(3, 4, 5)
        
        XCTAssertNoDiff((lhs + rhs).elements, [1, 2, 3, 4, 5])
    }
}
