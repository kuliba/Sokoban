//
//  CardGuardianReducerTests.swift
//
//
//  Created by Andryusina Nataly on 07.02.2024.
//

import XCTest
import CardGuardianModule

final class CardGuardianReducerTests: XCTestCase {
    
    // MARK: - test reduce
    
    func test_reduce_appear_shouldSetEffectNone() {
        
        assertEffect(.none, onEvent: .appear, state: .default)
    }
    
    func test_reduce_tapChangePin_shouldSetEffectNone() {
        
        assertEffect(.none, onEvent: .buttonTapped(.changePin), state: .default)
    }
    
    func test_reduce_tapToggleLockActive_shouldSetEffectNone() {
        
        assertEffect(.none, onEvent: .buttonTapped(.toggleLock(.active)), state: .default)
    }
    
    func test_reduce_tapToggleLockBlockedUnlockAvailable_shouldSetEffectNone() {
        
        assertEffect(.none, onEvent: .buttonTapped(.toggleLock(.blockedUnlockAvailable)), state: .default)
    }
    
    func test_reduce_tapToggleLockBlockedUnlockNotAvailable_shouldSetEffectNone() {
        
        assertEffect(.none, onEvent: .buttonTapped(.toggleLock(.blockedUnlockNotAvailable)), state: .default)
    }
    
    func test_reduce_tapShowOnMain_shouldSetEffectNone() {
        
        assertEffect(.none, onEvent: .buttonTapped(.showOnMain(true)), state: .default)
    }
    
    func test_reduce_tapHiddenOnMain_shouldSetEffectNone() {
        
        assertEffect(.none, onEvent: .buttonTapped(.showOnMain(false)), state: .default)
    }

    // MARK: - Helpers
    
    private typealias SUT = CardGuardianReducer
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
        _ initialState: State = .init(buttons: .default),
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

private typealias CardGuardianButton = CardGuardianState._Button

private extension CardGuardianButton {
    
    static let changePin: Self = .init(
        event: .changePin,
        title: "title",
        iconType: .changePin,
        subtitle: "subtitle")
    
    static let toggleLock: Self = .init(
        event: .toggleLock(.active),
        title: "title",
        iconType: .toggleLock,
        subtitle: "subtitle")
    
    static let showOnMain: Self = .init(
        event: .showOnMain(true),
        title: "title",
        iconType: .showOnMain,
        subtitle: "subtitle")
}

private extension Array where Element == CardGuardianButton {
    
    static let `default`: Self = [.changePin, .showOnMain, .toggleLock]
}

private extension CardGuardianReducer.State {
    
    static let `default`: Self = .init(buttons: .default, event: .none)
}
