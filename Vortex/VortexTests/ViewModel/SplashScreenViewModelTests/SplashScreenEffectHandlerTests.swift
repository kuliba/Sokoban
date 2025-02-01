//
//  SplashScreenEffectHandlerTests.swift
//  VortexTests
//
//  Created by Nikolay Pochekuev on 31.01.2025.
//

import XCTest
@testable import Vortex

final class SplashScreenEffectHandlerTests: XCTestCase {
    
    func test_startFirstTimer_shouldDispatchSplashEvent() {
        let (sut, startFirstTimerSpy, _) = makeSUT()
        
        startFirstTimerSpy.process((), completion: { result in
            if case .success = result { }
        })
        
        expect(sut, with: .startFirstTimer, toDeliver: .splash) {
            startFirstTimerSpy.complete(with: (), at: 0)
        }
        
        XCTAssertEqual(startFirstTimerSpy.callCount, 1)
    }

    func test_startSecondTimer_shouldCallStartSecondTimerAndDispatchNoSplashEvent() {
        let (sut, _, startSecondTimerSpy) = makeSUT()
        
        expect(sut, with: .startSecondTimer, toDeliver: .noSplash) {
            startSecondTimerSpy.complete(with: (), at: 0)
        }
        
        XCTAssertEqual(startSecondTimerSpy.callCount, 1)
    }
    
    // MARK: - Helpers
    private typealias SUT = SplashScreenEffectHandler
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    private typealias TimerSpy = Spy<Void, Void, Never>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        startFirstTimerSpy: TimerSpy,
        startSecondTimerSpy: TimerSpy
    ) {
        
        let startFirstTimerSpy = TimerSpy()
        let startSecondTimerSpy = TimerSpy()
        let sut = SUT(
            startFirstTimer: { completion in
                startFirstTimerSpy.process(completion: completion)
            },
            startSecondTimer: { completion in
                startSecondTimerSpy.process(completion: completion)
            }
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(startFirstTimerSpy, file: file, line: line)
        trackForMemoryLeaks(startSecondTimerSpy, file: file, line: line)
        
        return (sut, startFirstTimerSpy, startSecondTimerSpy)
    }
    
    private func expect(
        _ sut: SUT,
        with effect: Effect,
        toDeliver expectedEvent: Event,
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        
        let exp = expectation(description: "wait for event")
        
        sut.handleEffect(effect) { event in
            XCTAssertEqual(event, expectedEvent, file: file, line: line)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
    }
}
