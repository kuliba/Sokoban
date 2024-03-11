//
//  StackTests.swift
//
//
//  Created by Igor Malyarov on 05.03.2024.
//

import ForaTools
import XCTest

final class StackTests: XCTestCase {
    
    func test_init_withOneElement() {
        
        let first = Item()
        let sut = SUT(first)
        
        XCTAssertNoDiff(sut.peek(), first)
    }
    
    func test_init_withTwoElements() {
        
        let first = Item()
        let second = Item()
        var sut = SUT(first, second)
        
        XCTAssertNoDiff(sut.pop(), second)
        XCTAssertNoDiff(sut.pop(), first)
        
        XCTAssertNotEqual(first, second)
    }
    
    func test_init_withArrayOfOne() {
        
        let first = Item()
        var sut = SUT([first])
        
        XCTAssertNoDiff(sut.pop(), first)
    }
    
    func test_init_withArray() {
        
        let first = Item()
        let second = Item()
        var sut = SUT([first, second])
        
        XCTAssertNoDiff(sut.pop(), second)
        XCTAssertNoDiff(sut.pop(), first)
        
        XCTAssertNotEqual(first, second)
    }
    
    func test_stackEquality() {
        
        let firstItem = Item()
        let secondItem = Item()
        
        let first = SUT(firstItem, secondItem)
        let second = SUT([firstItem, secondItem])
        
        XCTAssertNoDiff(first, second)
    }
    
    func test_pop_shouldDeliverNilOnEmpty() {
        
        var sut = makeSUT()
        
        XCTAssertNil(sut.pop())
    }
    
    func test_pop_shouldRemoveLastElement() {
        
        let first = Item()
        var sut = makeSUT(first)
        
        XCTAssertNoDiff(sut.pop(), first)
        XCTAssertNil(sut.pop())
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
        
        var sut = makeSUT()
        XCTAssertNil(sut.pop())

        let first = Item()
        sut.push(first)
        XCTAssertNoDiff(sut.peek(), first)
        
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
        
        var sut = makeSUT()
        XCTAssertNoDiff(sut.top, nil)
        
        let first = Item()
        sut.push(first)
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
        XCTAssertNil(sut.pop())
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
    
    func test_top_set_shouldNotChangeEmptyOnNil() {
        
        let initial = makeSUT()
        var sut = initial
        
        sut.top = nil
        
        XCTAssertNoDiff(sut, initial)
    }
    
    func test_top_set_shouldEmptyStackOfOneOnNil() {
        
        let first = Item()
        var sut = makeSUT(first)
        
        sut.top = nil
        
        XCTAssert(sut.isEmpty)
    }
    
    func test_top_set_shouldRemoveLastElementOnNil() {
        
        let first = Item()
        let second = Item()
        var sut = makeSUT(first, second)
        
        sut.top = nil
        
        XCTAssertNoDiff(sut.top, first)
        XCTAssertNotEqual(first, second)
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
        XCTAssertNil(sut.pop())
    }
    
    func test_isEmpty_shouldDeliverFalseOnEmptyStack() {
        
        var sut = makeSUT()
        XCTAssert(sut.isEmpty)

        let first = Item()
        sut.push(first)
        XCTAssertFalse(sut.isEmpty)
        
        let second = Item()
        sut.push(second)
        XCTAssertFalse(sut.isEmpty)
        
        let last = Item()
        sut.push(last)
        XCTAssertFalse(sut.isEmpty)
        
        XCTAssertNoDiff(sut.pop(), last)
        XCTAssertFalse(sut.isEmpty)
        
        XCTAssertNoDiff(sut.pop(), second)
        XCTAssertFalse(sut.isEmpty)
        
        XCTAssertNoDiff(sut.pop(), first)
        XCTAssert(sut.isEmpty)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = Stack<Item>
    
    private struct Item: Equatable {
        
        let value: String
        
        init(value: String = UUID().uuidString) {
            
            self.value = value
        }
    }
    
    private func makeSUT(
        _ items: Item...,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(items)
        
        return sut
    }
    
    private func makeSUT(
        _ items: [Item],
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(items)
        
        return sut
    }
}

