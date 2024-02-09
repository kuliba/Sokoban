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
    
    func test_reduce_appear_shouldSetAppearEffectNone() {
        
        assertEvent(expectedEvent: .appear, onEvent: .appear)
    }
    
    func test_reduce_tapChangePin_shouldSetChangePinEffectNone() {
        
        assertEvent(
            expectedEvent: .buttonTapped(.changePin),
            onEvent: .buttonTapped(.changePin)
        )
    }
    
    func test_reduce_tapToggleLockActive_shouldSetToggleLockActiveEffectNone() {
        
        assertEvent(
            expectedEvent: .buttonTapped(.toggleLock(.active)),
            onEvent: .buttonTapped(.toggleLock(.active))
        )
    }
    
    func test_reduce_tapToggleLockBlockedUnlockAvailable_shouldSetToggleLockBlockedUnlockAvailableEffectNone() {
        
        assertEvent(
            expectedEvent: .buttonTapped(.toggleLock(.blockedUnlockAvailable)),
            onEvent: .buttonTapped(.toggleLock(.blockedUnlockAvailable))
        )
    }
    
    func test_reduce_tapToggleLockBlockedUnlockNotAvailable_shouldSetToggleLockBlockedUnlockNotAvailableEffectNone() {
        
        assertEvent(
            expectedEvent: .buttonTapped(.toggleLock(.blockedUnlockNotAvailable)),
            onEvent: .buttonTapped(.toggleLock(.blockedUnlockNotAvailable))
        )
    }
    
    func test_reduce_tapShowOnMain_shouldSetShowOnMainEffectNone() {
        
        assertEvent(
            expectedEvent: .buttonTapped(.showOnMain),
            onEvent: .buttonTapped(.showOnMain)
        )
    }
    
    // MARK: - Helpers
    
    private typealias SUT = CardGuardianReducer
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    
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
    ) -> (State, Effect?) {
        
        return sut.reduce(initialState, event)
    }
    
    private func assertEvent(
        sut: SUT? = nil,
        expectedEvent: Event,
        expectedEffect: Effect? = .none,
        onEvent event: Event,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        
        let sut = sut ?? makeSUT(file: file, line: line)
        
        let received = reduce(sut, event: event)
        
        XCTAssertNoDiff(received.0.event, expectedEvent, file: file, line: line)
        XCTAssertNoDiff(received.1, expectedEffect, file: file, line: line)
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
        event: .showOnMain,
        title: "title",
        iconType: .showOnMain,
        subtitle: "subtitle")
}

private extension Array where Element == CardGuardianButton {
    
    static let `default`: Self = [.changePin, .showOnMain, .toggleLock]
}
