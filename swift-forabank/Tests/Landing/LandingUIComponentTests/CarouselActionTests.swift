//
//  CarouselActionTests.swift
//
//
//  Created by Andryusina Nataly on 10.10.2024.
//

@testable import LandingUIComponent
import XCTest

final class CarouselActionTests: XCTestCase {
    
    //MARK: - test itemAction
    
    func test_itemAction_actionNil_LinkNil_shouldNotCallAction() {
                
        assertItemAction(
            for: nil,
            link: nil,
            [])
    }
    
    func test_itemAction_actionGoToMain_LinkNil_shouldCallGoToMan() {
                
        assertItemAction(
            for: .init(type: "goToMain", target: nil),
            link: nil,
            [.goMain])
    }

    func test_itemAction_actionGoToMain_LinkNotNil_shouldCallGoToMan() {
        
        let link = anyMessage()

        assertItemAction(
            for: .init(type: "goToMain", target: nil),
            link: link,
            [.goMain])
    }

    func test_itemAction_actionNil_linkNotNil_shouldCallOpenUrl() {
        
        let link = anyMessage()
        
        assertItemAction(
            for: nil,
            link: link,
            [.openLink])
    }
    
    func test_itemAction_unknowAction_linkNil_shouldNotCallAction() {
        
        let type = anyMessage()
        
        assertItemAction(
            for: .init(type: type, target: nil),
            link: nil,
            [])
    }

    func test_itemAction_unknowAction_linkNotNil_shouldCallOpenUrl() {
        
        let type = anyMessage()
        let link = anyMessage()

        assertItemAction(
            for: .init(type: type, target: nil),
            link: link,
            [.openLink])
    }

    // MARK: - Helpers
   
    private typealias Carousel = UILanding.Carousel

    private func assertItemAction(
        for itemAction: ItemAction?,
        link: String?,
        _ expectedActionTypes: [ActionType]
    ) {
        
        var received = [ActionType]()
        
        Carousel.action(
            itemAction: itemAction,
            link: link,
            actions: .init(
                openUrl: { _ in received.append(.openLink) },
                goToMain: { received.append(.goMain) }))()
        
        XCTAssertEqual(received, expectedActionTypes)
    }

    enum ActionType {
        
        case goMain
        case openLink
    }
}
