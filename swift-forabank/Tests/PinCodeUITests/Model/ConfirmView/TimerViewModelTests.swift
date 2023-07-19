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
        
        let timerViewModel = makeSUT(delay: 60)
        
        let formatter: DateComponentsFormatter = .timerViewFormatter

        XCTAssertEqual(timerViewModel.delay, 60)
        XCTAssertEqual(timerViewModel.description, "description")
        XCTAssertNotNil(timerViewModel.completeAction)
        XCTAssertEqual(timerViewModel.value, formatter.string(from: 60))
    }
    
    //MARK: - test update value
    
    func test_updateValue_shouldSetNewValue() {
        
        let timerViewModel = makeSUT(delay: 5)
        
        let formatter: DateComponentsFormatter = .timerViewFormatter

        let startTime = Date.timeIntervalSinceReferenceDate
        XCTAssertEqual(timerViewModel.delay, 5)
        XCTAssertEqual(timerViewModel.value, formatter.string(from: 5))

        XCTWaiter().wait(for: [.init()], timeout: 2)
        let time = Date()

        timerViewModel.updateValue(
            startTime: startTime,
            delay: 5,
            time: time
        )
        
        XCTAssertEqual(timerViewModel.value, formatter.string(from: 3))
    }
    
    func test_updateValue_notUpdateValueIfTimeEnd() {
        
        let delay: TimeInterval = 2
        
        let timerViewModel = makeSUT(delay: delay)
        
        let formatter: DateComponentsFormatter = .timerViewFormatter

        let startTime = Date.timeIntervalSinceReferenceDate
        XCTAssertEqual(timerViewModel.delay, delay)
        XCTAssertEqual(timerViewModel.value, formatter.string(from: delay))

        XCTWaiter().wait(for: [.init()], timeout: delay + 1)
        let time = Date()

        timerViewModel.updateValue(
            startTime: startTime,
            delay: delay,
            time: time
        )
        
        XCTAssertEqual(timerViewModel.value, formatter.string(from: 2))
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
