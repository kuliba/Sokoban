//
//  timerSwitchModelTests.swift
//  
//
//  Created by Igor Malyarov on 15.07.2023.
//

import Combine
import CvvPin
import XCTest

final class timerSwitchModelTests: XCTestCase {
    
    func test_init_shouldSetStateToOff() {
        
        let spy = makeSUT().spy
        
        XCTAssertNoDiff(spy.values, [.off])
    }
    
    func test_init_shouldSetStateToGiven() {
        
        let spy = makeSUT(initialState: .on).spy
        
        XCTAssertNoDiff(spy.values, [.on])
    }
    
    func test_turnOn_shouldSetStateToOnAndBackToOffOnGivenDelay() {
        
        let (sut, spy, scheduler) = makeSUT()
        
        sut.turnOn(forMS: 1_000)
        scheduler.advance(by: .milliseconds(999))
        
        XCTAssertNoDiff(spy.values, [.off, .on])
        
        scheduler.advance(by: .milliseconds(1))
        
        XCTAssertNoDiff(spy.values, [.off, .on, .off])
    }
    
    func test_turnOff_shouldSetStateToOffImmediately() {
        
        let (sut, spy, scheduler) = makeSUT()
        
        sut.turnOn(forMS: 1_000)
        scheduler.advance(by: .milliseconds(100))
        
        sut.turnOff()
        scheduler.advance()
        
        XCTAssertNoDiff(spy.values, [.off, .on, .off])
        scheduler.advance(to: .init(.now()))
    }
    
    func test_turnOff_shouldSetStateToOffOnceAfterTurnOff() {
        
        let (sut, spy, scheduler) = makeSUT()
        
        sut.turnOn(forMS: 1_000)
        scheduler.advance(by: .milliseconds(100))
        
        sut.turnOff()
        scheduler.advance()
        
        XCTAssertNoDiff(spy.values, [.off, .on, .off])
        
        scheduler.advance(to: .init(.now()))
        
        XCTAssertNoDiff(spy.values, [.off, .on, .off])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        initialState: TimerSwitchModel.State = .off,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: TimerSwitchModel,
        spy: ValueSpy<TimerSwitchModel.State>,
        scheduler: TestSchedulerOfDispatchQueue
    ) {
        let scheduler = DispatchQueue.test
        let sut = TimerSwitchModel(
            initialState: initialState,
            scheduler: scheduler.eraseToAnyScheduler()
        )
        let spy = ValueSpy(sut.$state)
        
        trackForMemoryLeaks(scheduler, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, spy, scheduler)
    }
}
