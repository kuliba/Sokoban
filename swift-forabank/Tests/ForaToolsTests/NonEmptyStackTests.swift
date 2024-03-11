//
//  NonEmptyStackTests.swift
//
//
//  Created by Igor Malyarov on 05.03.2024.
//

import ForaTools
import XCTest

final class NonEmptyStackTests: XCTestCase {
    
    func test_pop_shouldDeliverFirstElement() {
        
        let first = Item()
        var sut = makeSUT(first)
        
        XCTAssertNoDiff(sut.pop(), first)
        XCTAssertNoDiff(sut.pop(), first)
        XCTAssertNoDiff(sut.pop(), first)
    }
    
    func test_pop_shouldDeliverLastElement() {
        
        let first = Item()
        var sut = makeSUT(first)
        
        let second = Item()
        sut.push(second)
        
        let last = Item()
        sut.push(last)
        
        XCTAssertNoDiff(sut.pop(), last)
        XCTAssertNoDiff(sut.pop(), second)
        XCTAssertNoDiff(sut.pop(), first)
        
        XCTAssertNotEqual(first, second)
        XCTAssertNotEqual(first, last)
        XCTAssertNotEqual(second, last)
    }
    
    func test_peek_shouldDeliverLastElement() {
        
        let first = Item()
        var sut = makeSUT(first)
        XCTAssertNoDiff(sut.pop(), first)
        
        let second = Item()
        sut.push(second)
        XCTAssertNoDiff(sut.peek(), second)
        
        let last = Item()
        sut.push(last)
        XCTAssertNoDiff(sut.peek(), last)
        
        XCTAssertNotEqual(first, second)
        XCTAssertNotEqual(first, last)
        XCTAssertNotEqual(second, last)
    }
    
    func test_top_shouldDeliverLastElement() {
        
        let first = Item()
        var sut = makeSUT(first)
        XCTAssertNoDiff(sut.top, first)
        
        let second = Item()
        sut.push(second)
        XCTAssertNoDiff(sut.top, second)

        let last = Item()
        sut.push(last)
        XCTAssertNoDiff(sut.top, last)

        sut.pop()
        XCTAssertNoDiff(sut.top, second)

        sut.pop()
        XCTAssertNoDiff(sut.top, first)

        sut.pop()
        XCTAssertNoDiff(sut.top, first)
    }
    
    func test_top_set_shouldChangeFirstElement() {
        
        let first = Item()
        var sut = makeSUT(first)
        
        XCTAssertNoDiff(sut.top, first)
        XCTAssertNoDiff(sut.pop(), first)
        
        let new = Item()
        sut.top = new
        XCTAssertNoDiff(sut.top, new)
        XCTAssertNoDiff(sut.pop(), new)
        
        XCTAssertNotEqual(new, first)
    }
    
    func test_top_set_shouldChangeLastElement() {
        
        let first = Item()
        var sut = makeSUT(first)
        
        let second = Item()
        sut.push(second)
                
        let new = Item()
        sut.top = new
        XCTAssertNoDiff(sut.top, new)
        XCTAssertNoDiff(sut.pop(), new)
        
        XCTAssertNotEqual(first, second)
        XCTAssertNotEqual(first, new)
        XCTAssertNotEqual(second, new)
    }
    
    func test_count_shouldDeliverNumberOfElement() {
        
        let first = Item()
        var sut = makeSUT(first)
        XCTAssertEqual(sut.count, 1)
        
        let second = Item()
        sut.push(second)
        XCTAssertEqual(sut.count, 2)
        
        let last = Item()
        sut.push(last)
        XCTAssertEqual(sut.count, 3)
        
        sut.pop()
        XCTAssertEqual(sut.count, 2)
        
        sut.pop()
        XCTAssertEqual(sut.count, 1)
        
        sut.pop()
        XCTAssertEqual(sut.count, 1)
    }
    
    func test_isEmpty_shouldDeliverFalse() {
        
        let first = Item()
        var sut = makeSUT(first)
        XCTAssertFalse(sut.isEmpty)
        
        let second = Item()
        sut.push(second)
        XCTAssertFalse(sut.isEmpty)
        
        let last = Item()
        sut.push(last)
        XCTAssertFalse(sut.isEmpty)
        
        sut.pop()
        XCTAssertFalse(sut.isEmpty)
        
        sut.pop()
        XCTAssertFalse(sut.isEmpty)
        
        sut.pop()
        XCTAssertFalse(sut.isEmpty)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = NonEmptyStack<Item>
    
    private struct Item: Equatable {
        
        let value: String
        
        init(value: String = UUID().uuidString) {
            
            self.value = value
        }
    }
    
    private func makeSUT(
        _ item: Item,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(item)
        
        return sut
    }
}

