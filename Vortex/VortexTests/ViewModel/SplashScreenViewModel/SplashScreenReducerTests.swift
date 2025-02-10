//
//  SplashScreenReducerTests.swift
//  VortexTests
//
//  Created by Nikolay Pochekuev on 30.01.2025.
//

@testable import Vortex
import SwiftUI
import XCTest

final class SplashScreenReducerTests: XCTestCase {
    
    func test_start_whenAlreadyStarted_shouldNotDeliverEffect() {
        
        assertEffect(.start, on: .initialSplashData.started(), effect: nil)
    }
    
    func test_splash_whenAlreadySplashed_shouldNotDeliverEffect() {
        
        assertEffect(.splash, on: .initialSplashData.splashed(), effect: nil)
    }
    
    func test_noSplash_whenAlreadyNoSplash_shouldNotDeliverEffect() {
        
        assertEffect(.noSplash, on: .initialSplashData.noSplash(), effect: nil)
    }
    
    func test_start_whenAlreadyStarted_shouldNotChangeState() {
        
        assertState(.start, on: .initialSplashData.started())
    }
    
    func test_splash_whenAlreadySplashed_shouldNotChangeState() {
        
        assertState(.splash, on: .initialSplashData.splashed())
    }
    
    func test_noSplash_whenAlreadyNoSplash_shouldNotChangeState() {
        
        assertState(.noSplash, on: .initialSplashData.noSplash())
    }

    func test_start_afterNoSplash_shouldDeliverStartFirstTimerEffect() {
        
        assertEffect(.start, on: .initialSplashData.noSplash(), effect: .startFirstTimer)
    }
    
    func test_splash_afterStarted_shouldDeliverStartSecondTimerEffect() {
        
        assertEffect(.splash, on: .initialSplashData.started(), effect: .startSecondTimer)
    }
    
    func test_start_toSplashTransition_shouldChangeState() {
        
        assertState(.splash, on: .initialSplashData.started()) { $0 = $0.splashed() }
    }
    
    func test_splash_toNoSplashTransition_shouldChangeState() {
        
        assertState(.noSplash, on: .initialSplashData.splashed()) { $0 = $0.noSplash() }
    }

    // MARK: - Helpers
    
    private typealias SUT = SplashScreenReducer
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    private typealias UpdateStateToExpected = (_ state: inout State) -> Void
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func assertState(
        _ event: Event,
        on state: State,
        updateStateToExpected: UpdateStateToExpected? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = makeSUT()
        
        var expectedState = state
        updateStateToExpected?(&expectedState)
        
        let (receivedState, _) = sut.reduce(state, event)
        
        XCTAssertNoDiff(
            receivedState.data,
            expectedState.data,
            "\nExpected \(expectedState), but got \(receivedState) instead.",
            file: file, line: line
        )
    }
    
    private func assertEffect(
        sut: SUT? = nil,
        _ event: Event,
        on state: State,
        effect expectedEffect: Effect?,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT()
        
        let (_, receivedEffect) = sut.reduce(state, event)
        
        XCTAssertNoDiff(
            receivedEffect,
            expectedEffect,
            "\nExpected \(String(describing: expectedEffect)), but got \(String(describing: receivedEffect)) instead.",
            file: file, line: line
        )
    }
}
