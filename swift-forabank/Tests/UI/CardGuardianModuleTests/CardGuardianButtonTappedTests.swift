//
//  CardGuardianButtonTappedTests.swift
//  
//
//  Created by Andryusina Nataly on 08.02.2024.
//

import XCTest
@testable import CardGuardianModule

final class CardGuardianButtonTappedTests: XCTestCase {
    
    // MARK: - event
    
    func test_eventChangePin_shouldSetEventChangePin() {
        
        isEqual(.changePin, .buttonTapped(.changePin))
    }
    
    func test_eventShowOnMain_shouldSetEventShowOnMain() {

        isEqual(.showOnMain, .buttonTapped(.showOnMain))
    }
    
    func test_eventToggleLockActive_shouldSetEventToggleLockActive() {

        isEqual(.toggleLock(.active), .buttonTapped(.toggleLock(.active)))
    }
    
    func test_eventToggleLockBlockedUnlockAvailable_shouldSetEventToggleLockBlockedUnlockAvailable() {

        isEqual(.toggleLock(.blockedUnlockAvailable), .buttonTapped(.toggleLock(.blockedUnlockAvailable)))
    }

    func test_eventToggleLockBlockedUnlockNotAvailable_shouldSetEventToggleLockBlockedUnlockNotAvailable() {

        isEqual(.toggleLock(.blockedUnlockNotAvailable), .buttonTapped(.toggleLock(.blockedUnlockNotAvailable)))
    }
    
    private func isEqual(
        _ input: CardGuardian.ButtonTapped,
        _ output: CardGuardianEvent
    ) {
        return XCTAssertNoDiff(input.event, output)
    }
}
