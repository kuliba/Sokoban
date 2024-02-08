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
        
        let sut = makeSUT()
        let event: Event = .appear
        
        let result = reduce(sut, event: event)
        
        XCTAssertNoDiff(result.0.event, event)
        
        XCTAssertNoDiff(result.1, .none)
    }
    
    func test_reduce_tapChangePin_shouldSetChangePinEffectNone() {
        
        let sut = makeSUT()
        let event: Event = .buttonTapped(.changePin)
        
        let result = reduce(sut, event: event)
                
        XCTAssertNoDiff(result.0.event, event)
        
        XCTAssertNoDiff(result.1, .none)
    }

    func test_reduce_tapToggleLockActive_shouldSetToggleLockActiveEffectNone() {
        
        let sut = makeSUT()
        let event: Event = .buttonTapped(.toggleLock(.active))
        
        let result = reduce(sut, event: event)
                
        XCTAssertNoDiff(result.0.event, event)
        
        XCTAssertNoDiff(result.1, .none)
    }

    func test_reduce_tapToggleLockBlockedUnlockAvailable_shouldSetToggleLockBlockedUnlockAvailableEffectNone() {
        
        let sut = makeSUT()
        let event: Event = .buttonTapped(.toggleLock(.blockedUnlockAvailable))
        
        let result = reduce(sut, event: event)
                
        XCTAssertNoDiff(result.0.event, event)
        
        XCTAssertNoDiff(result.1, .none)
    }

    func test_reduce_tapToggleLockBlockedUnlockNotAvailable_shouldSetToggleLockBlockedUnlockNotAvailableEffectNone() {
        
        let sut = makeSUT()
        let event: Event = .buttonTapped(.toggleLock(.blockedUnlockNotAvailable))
        
        let result = reduce(sut, event: event)
                
        XCTAssertNoDiff(result.0.event, event)
        
        XCTAssertNoDiff(result.1, .none)
    }
    
    func test_reduce_tapShowOnMain_shouldSetShowOnMainEffectNone() {
        
        let sut = makeSUT()
        let event: Event = .buttonTapped(.showOnMain)
        
        let result = reduce(sut, event: event)
                
        XCTAssertNoDiff(result.0.event, event)
        
        XCTAssertNoDiff(result.1, .none)
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
