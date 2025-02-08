//
//  SplashScreenEffectHandlerTests.swift
//  VortexTests
//
//  Created by Nikolay Pochekuev on 31.01.2025.
//

import XCTest
@testable import Vortex

final class SplashScreenEffectHandlerTests: XCTestCase {
    
    func test_initialState_shouldNotTriggerAnyTimers() {
        let (_, startPhaseOneSpy, startPhaseTwoSpy) = makeSUT()
        
        XCTAssertEqual(startPhaseOneSpy.callCount, 0)
        XCTAssertEqual(startPhaseTwoSpy.callCount, 0)
    }
    
    func test_startFirstTimer_shouldDispatchSplashEvent() {
        let (sut, startPhaseOneSpy, _) = makeSUT()

        expect(sut, with: .startFirstTimer, toDeliver: .splash) {
            startPhaseOneSpy.complete(with: (), at: 0)
            
            XCTAssertEqual(startPhaseOneSpy.callCount, 1)
        }
    }

    func test_startSecondTimer_shouldCallStartSecondTimerAndDispatchNoSplashEvent() {
        let (sut, _, startPhaseTwoSpy) = makeSUT()
        
        expect(sut, with: .startSecondTimer, toDeliver: .noSplash) {
            startPhaseTwoSpy.complete(with: (), at: 0)
            
            XCTAssertEqual(startPhaseTwoSpy.callCount, 1)
        }
    }
    
    // MARK: - Helpers
    private typealias SUT = SplashScreenEffectHandler
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    private typealias PhaseSpy = Spy<Void, Void, Never>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        startPhaseOne: PhaseSpy,
        startPhaseTwo: PhaseSpy
    ) {
        let startPhaseOneSpy = PhaseSpy()
        let startPhaseTwoSpy = PhaseSpy()
        let sut = SUT(
            startFirstTimer: { startPhaseOneSpy.process(completion: $0) },
            startSecondTimer: { startPhaseTwoSpy.process(completion: $0) }
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(startPhaseOneSpy, file: file, line: line)
        trackForMemoryLeaks(startPhaseTwoSpy, file: file, line: line)
        
        return (sut, startPhaseOneSpy, startPhaseTwoSpy)
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
