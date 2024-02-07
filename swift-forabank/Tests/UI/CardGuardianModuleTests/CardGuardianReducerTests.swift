//
//  CardGuardianReducerTests.swift
//  
//
//  Created by Andryusina Nataly on 07.02.2024.
//

import XCTest
import CardGuardianModule

private typealias CardGuardianButton = CardGuardianState._Button

final class CardGuardianReducerTests: XCTestCase {
    
    // MARK: - test reduce
    
    func test_reduce_appear_shouldSetAppearEffectNone() {
        
        let sut = makeSUT(event: .appear)
        
        XCTAssertNoDiff(sut.0.event, .appear)
        
        XCTAssertNoDiff(sut.1, .none)
    }
    
    func test_reduce_tapChangePin_shouldSetChangePinEffectNone() {
        
        let sut = makeSUT(event: .buttonTapped(.changePin))
                
        XCTAssertNoDiff(sut.0.event, .buttonTapped(.changePin))
        
        XCTAssertNoDiff(sut.1, .none)
    }

    func test_reduce_tapToggleLockActive_shouldSetToggleLockActiveEffectNone() {
        
        let sut = makeSUT(event: .buttonTapped(.toggleLock(.active)))
                
        XCTAssertNoDiff(sut.0.event, .buttonTapped(.toggleLock(.active)))
        
        XCTAssertNoDiff(sut.1, .none)
    }

    func test_reduce_tapToggleLockBlockedUnlockAvailable_shouldSetToggleLockBlockedUnlockAvailableEffectNone() {
        
        let sut = makeSUT(event: .buttonTapped(.toggleLock(.blockedUnlockAvailable)))
                
        XCTAssertNoDiff(sut.0.event, .buttonTapped(.toggleLock(.blockedUnlockAvailable)))
        
        XCTAssertNoDiff(sut.1, .none)
    }

    func test_reduce_tapToggleLockBlockedUnlockNotAvailable_shouldSetToggleLockBlockedUnlockNotAvailableEffectNone() {
        
        let sut = makeSUT(event: .buttonTapped(.toggleLock(.blockedUnlockNotAvailable)))
                
        XCTAssertNoDiff(sut.0.event, .buttonTapped(.toggleLock(.blockedUnlockNotAvailable)))
        
        XCTAssertNoDiff(sut.1, .none)
    }
    
    func test_reduce_tapShowOnMain_shouldSetShowOnMainEffectNone() {
        
        let sut = makeSUT(event: .buttonTapped(.showOnMain))
                
        XCTAssertNoDiff(sut.0.event, .buttonTapped(.showOnMain))
        
        XCTAssertNoDiff(sut.1, .none)
    }

    // MARK: - Helpers
        
    private func makeSUT(
        event: CardGuardianEvent
    ) -> (CardGuardianState, CardGuardianEffect?) {
        
        return CardGuardianReducer().reduce(.init(buttons: .default), event)
    }
}

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
