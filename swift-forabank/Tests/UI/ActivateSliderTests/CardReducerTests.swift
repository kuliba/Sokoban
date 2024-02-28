//
//  CardReducerTests.swift
//  
//
//  Created by Andryusina Nataly on 27.02.2024.
//

import XCTest
import ActivateSlider

final class CardReducerTests: XCTestCase {

    // MARK: - test reduce
    
    func test_activateCard_shouldSetEffectNone() {
        
        assertEffect(.none, onEvent: .activateCard, state: .status(.none))
    }
    
    func test_confirmActivateCancel_shouldSetEffectNone() {
        
        assertEffect(.none, onEvent: .confirmActivate(.cancel), state: .status(.none))
    }
    
    func test_confirmActivate_shouldSetEffectActivate() {
        
        assertEffect(.activate, onEvent: .confirmActivate(.activate), state: .status(.none))
    }
    
    func test_activateCardResponseConnectivityError_shouldSetEffectNone() {
        
        assertEffect(.none, onEvent: .activateCardResponse(.connectivityError), state: .status(.none))
    }
    
    func test_activateCardResponseServerError_shouldSetEffectNone() {
        
        assertEffect(.none, onEvent: .activateCardResponse(.serverError("error")), state: .status(.none))
    }

    func test_activateCardResponseSuccess_shouldSetEffectDismiss() {
        
        assertEffect(.some(.dismiss(.seconds(1))), onEvent: .activateCardResponse(.success), state: .status(.none))
    }

    func test_dismissActivate_shouldSetEffectNone() {
        
        assertEffect(.none, onEvent: .dismissActivate, state: .status(.none))
    }

    // MARK: - Helpers
    
    private typealias SUT = CardReducer
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    private typealias Result = (State, Effect?)
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut)
    }
    
    private func reduce(
        _ sut: SUT,
        _ initialState: State = .status(.none),
        event: Event
    ) -> Result {
        
        return sut.reduce(initialState, event)
    }
    
    private func assertEffect(
        sut: SUT? = nil,
        _ expectedEffect: Effect?,
        onEvent event: Event,
        state: State,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        
        let sut = sut ?? makeSUT(file: file, line: line)
        let (_, receivedEffect): Result = sut.reduce(state, event)
        
        XCTAssertNoDiff(receivedEffect, expectedEffect, file: file, line: line)
    }
}
