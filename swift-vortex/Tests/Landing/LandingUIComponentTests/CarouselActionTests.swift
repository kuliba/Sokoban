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
    
    func test_itemAction_actionLanding_LinkNil_shouldCallLanding() {
         
        let target = anyMessage()

        assertItemAction(
            for: .init(type: "LANDING", target: target),
            link: nil,
            [.landing(target)])
    }

    func test_itemAction_actionGoToMain_LinkNotNil_shouldCallLanding() {
        
        let link = anyMessage()
        let target = anyMessage()

        assertItemAction(
            for: .init(type: "LANDING", target: target),
            link: link,
            [.landing(target)])
    }

    func test_itemAction_actionCardOrderList_LinkNil_shouldCallOrderCard() {
                
        assertItemAction(
            for: .init(type: "cardOrderList", target: nil),
            link: nil,
            [.orderCard])
    }

    func test_itemAction_actionCardOrderList_LinkNotNil_shouldCallOrderCard() {
        
        let link = anyMessage()

        assertItemAction(
            for: .init(type: "cardOrderList", target: nil),
            link: link,
            [.orderCard])
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

    func test_itemAction_actionOrderCard_LinkNil_shouldNotCallAction() {
                
        assertItemAction(
            for: .init(type: "orderCard", target: nil),
            link: nil,
            [])
    }

    func test_itemAction_actionOrderCard_LinkNotNil_shouldCallOpenLink() {
        
        let link = anyMessage()

        assertItemAction(
            for: .init(type: "orderCard", target: nil),
            link: link,
            [.openLink])
    }
    
    func test_itemAction_action_housingAndCommumalService_LinkNil_shouldCallPaymentAction() {
          
        let type = String.housingAndCommumalService
        
        assertItemAction(
            for: .init(type: type, target: nil),
            link: nil,
            [.payment(type)])
    }

    func test_itemAction_action_housingAndCommumalService_LinkNotNil_shouldCallPaymentAction() {
        
        let link = anyMessage()
        let type = String.housingAndCommumalService

        assertItemAction(
            for: .init(type: type, target: nil),
            link: link,
            [.payment(type)])
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
                goToMain: { received.append(.goMain) }, 
                orderCard: { received.append(.orderCard) },
                landing: { received.append(.landing($0)) },
                payment: { received.append(.payment($0)) }
            ))()
        
        XCTAssertEqual(received, expectedActionTypes)
    }

    enum ActionType: Equatable {
        
        case goMain
        case landing(String?)
        case openLink
        case orderCard
        case payment(String)
    }
}

private extension String {
    
    static let housingAndCommumalService = "HOUSING_AND_COMMUNAL_SERVICE"
}
