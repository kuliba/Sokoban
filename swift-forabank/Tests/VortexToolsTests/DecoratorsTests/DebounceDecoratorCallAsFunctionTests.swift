//
//  DebounceDecoratorCallAsFunctionTests.swift
//
//
//  Created by Igor Malyarov on 20.03.2024.
//

import VortexTools
import XCTest

final class DebounceDecoratorCallAsFunctionTests: XCTestCase {
    
    func test_callAsFunction_shouldCallOnce() {
        
        let sut = makeSUT()
        let exp = expectation(description: "debounce should omit subsequent calls")
        
        sut { exp.fulfill() }
        sut { exp.fulfill() }
        sut { exp.fulfill() }
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_callAsFunction_shouldNotCreateRaceCondition() {
        
        let sut = makeSUT(delay: 0.1)
        let expectation = expectation(description: "DebounceRace")
        
        let block = { expectation.fulfill() }
        
        DispatchQueue.global().async { sut(block: block) }
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.05) { sut(block: block) }
        
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
