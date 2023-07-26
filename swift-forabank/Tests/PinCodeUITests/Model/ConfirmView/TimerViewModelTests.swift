//
//  TimerViewModelTests.swift
//  
//
//  Created by Andryusina Nataly on 18.07.2023.
//

@testable import PinCodeUI

import XCTest
import Foundation

final class TimerViewModelTests: XCTestCase {

    //MARK: - test init
    
    func test_init_shouldSetAllValue() {
        
        let sut = makeSUT(delay: 60)
        
        let formatter: DateComponentsFormatter = .timerViewFormatter

        XCTAssertEqual(sut.delay, 60)
        XCTAssertEqual(sut.description, "description")
        XCTAssertNotNil(sut.completeAction)
        XCTAssertEqual(sut.value, formatter.string(from: 60))
    }
    
    //MARK: - test update value
    
    func test_updateValue_shouldSetNewValue() {
        
        let sut = makeSUT(delay: 5)
        
        let formatter: DateComponentsFormatter = .timerViewFormatter

        let startTime = Date.timeIntervalSinceReferenceDate
        XCTAssertEqual(sut.delay, 5)
        XCTAssertEqual(sut.value, formatter.string(from: 5))

        XCTWaiter().wait(for: [.init()], timeout: 2)
        let time = Date()

        sut.updateValue(
            startTime: startTime,
            delay: 5,
            time: time
        )
        
        XCTAssertEqual(sut.value, formatter.string(from: 3))
    }
    
    func test_updateValue_notUpdateValueIfTimeEnd() {
        
        let delay: TimeInterval = 2
        
        let sut = makeSUT(delay: delay)
        
        let formatter: DateComponentsFormatter = .timerViewFormatter

        let startTime = Date.timeIntervalSinceReferenceDate
        XCTAssertEqual(sut.delay, delay)
        XCTAssertEqual(sut.value, formatter.string(from: delay))

        XCTWaiter().wait(for: [.init()], timeout: delay + 1)
        let time = Date()

        sut.updateValue(
            startTime: startTime,
            delay: delay,
            time: time
        )
        
        XCTAssertEqual(sut.value, formatter.string(from: 2))
    }
    
    func test_updateValue_IfTimeEnd_shouldShowRepeatButton() {
        
        let delay: TimeInterval = 2
        
        let sut = makeSUT(delay: delay)

        let startTime = Date.timeIntervalSinceReferenceDate

        XCTAssertFalse(sut.needRepeatButton)

        XCTWaiter().wait(for: [.init()], timeout: delay)
        
        let time = Date()

        sut.updateValue(
            startTime: startTime,
            delay: delay,
            time: time
        )
        
        XCTAssertTrue(sut.needRepeatButton)
    }
    
    //MARK: - Helpers

    private func makeSUT(
        delay: TimeInterval = 2,
        description: String = "description",
        file: StaticString = #file,
        line: UInt = #line
    ) -> ConfirmViewModel.TimerViewModel {
        
        let sut: ConfirmViewModel.TimerViewModel = .init(
            delay: delay,
            description: description,
            completeAction: {})
        
        trackForMemoryLeaks(sut, file: file, line: line)
            
        return (sut)
    }
}
