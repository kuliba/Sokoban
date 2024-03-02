//
//  CardGuardianStateTests.swift
//
//
//  Created by Andryusina Nataly on 31.01.2024.
//

import CardGuardianUI
import XCTest

private typealias CardGuardianButton = CardGuardianState._Button

final class CardGuardianStateTests: XCTestCase {

    //MARK: - test init config

    func test_init_shouldSetAllValue() {
                
        let sut = makeSUT(buttons: [.button], event: .appear)
        
        XCTAssertNoDiff(sut.buttons, [.button])
        XCTAssertNoDiff(sut.event, .appear)
    }
    
    //MARK: - test updateEvent

    func test_updateEvent_appear_shouldSetNewValue() {
                
        var sut = makeSUT(event: .none)
        
        XCTAssertNoDiff(sut.event, .none)

        sut.updateEvent(.appear)
        
        XCTAssertNoDiff(sut.event, .appear)
    }
    
    func test_updateEvent_tapButton_shouldSetNewValue() {
                
        var sut = makeSUT(event: .appear)
        
        XCTAssertNoDiff(sut.event, .appear)

        sut.updateEvent(.buttonTapped(.changePin(.default)))
        
        XCTAssertNoDiff(sut.event, .buttonTapped(.changePin(.default)))
    }
        
    // MARK: - Helpers
        
    private func makeSUT(
        buttons: [CardGuardianButton] = [.button],
        event: CardGuardianEvent? = nil
    ) -> CardGuardianState {
        
        return .init(
            buttons: buttons,
            event: event
        )
    }
}

private extension CardGuardianButton {
    
    static let button: Self = .init(
        event: .changePin(.default),
        title: "title",
        iconType: .changePin,
        subtitle: "subtitle")
}

private extension Card {
    
    static let `default`: Self = .init(
        cardId: 1,
        cardNumber: "111",
        cardGuardianStatus: .active
    )
}
