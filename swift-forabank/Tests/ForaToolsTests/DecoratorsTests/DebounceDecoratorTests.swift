//
//  DebounceDecoratorTests.swift
//
//
//  Created by Igor Malyarov on 20.03.2024.
//

import ForaTools
import XCTest

final class DebounceDecoratorTests: XCTestCase {
    
    func test_debounce_shouldCallOnce() {
        
        let sut = makeSUT()
        let exp = expectation(description: "debounce should omit subsequent calls")
        
        sut.debounce { exp.fulfill() }
        sut.debounce { exp.fulfill() }
        sut.debounce { exp.fulfill() }
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_debounce_shouldNotCallOnInstanceDeallocation() {
        
        var sut: SUT? = makeSUT()
        let exp = self.expectation(description: "DebounceDeallocation")
        exp.isInverted = true
        
        sut?.debounce { exp.fulfill() }
        sut = nil
        
        waitForExpectations(timeout: 0.2) { error in
            
            XCTAssertNil(error, "Debounce action was called after instance deallocation")
        }
    }
    
    func test_debounce_shouldNotCreateRaceCondition() {
        
        let sut = makeSUT(delay: 0.1)
        let expectation = expectation(description: "DebounceRace")
        
        let block = { expectation.fulfill() }
        
        DispatchQueue.global().async { sut.debounce(block: block) }
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.05) {
            sut.debounce(block: block)
        }
        
        waitForExpectations(timeout: 0.3) { error in
            
            XCTAssertNil(error, "Debounce with race condition test timed out")
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = DebounceDecorator
    
    private func makeSUT(
        delay: TimeInterval = 0.1,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(delay: delay)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}
