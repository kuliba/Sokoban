//
//  SplashScreenEffectHandlerTests.swift
//  VortexTests
//
//  Created by Nikolay Pochekuev on 31.01.2025.
//

import XCTest
@testable import Vortex

final class SplashScreenEffectHandlerTests: XCTestCase {
    
    func test_startFirstTimer_dispatchesSplashEvent() {
        
        var events: [SplashScreenEvent] = []
        
        let effectHandler = makeSUT()
        
        effectHandler.handleEffect(.startFirstTimer) { events.append($0) }
        
        XCTAssertEqual(events, [.splash])
    }
    
    func test_startSecondTimer_dispatchesNoSplashEvent() {
       
        var events: [SplashScreenEvent] = []
        
        let effectHandler = makeSUT(startSecondTimer: { completion in completion() })
        
        effectHandler.handleEffect(.startSecondTimer) { events.append($0) }
        
        XCTAssertEqual(events, [.noSplash])
    }
    
    // MARK: - Helpers
    private typealias SUT = SplashScreenEffectHandler

    private func makeSUT(
        startFirstTimer: @escaping SplashScreenEffectHandler.StartTimer = { $0() },
        startSecondTimer: @escaping SplashScreenEffectHandler.StartTimer = { $0() },
        file: StaticString = #file,
        line: UInt = #line
    ) -> SplashScreenEffectHandler {
        
        let sut = SUT(
            startFirstTimer: startFirstTimer,
            startSecondTimer: startSecondTimer
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}
