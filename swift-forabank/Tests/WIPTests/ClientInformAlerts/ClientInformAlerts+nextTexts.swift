//
//  ClientInformAlerts+nextTexts.swift
//
//
//  Created by Igor Malyarov on 28.11.2024.
//

import XCTest

final class ClientInformAlerts_nextTexts: XCTestCase {
    
    // MARK: - InformAlerts
    
    func test_shouldNotChangeEmptyInformAlerts() {
        
        var alerts = makeSUT(informAlerts: [])
        XCTAssertTrue(alerts.informAlerts.isEmpty)
        
        alerts.next()
        
        XCTAssertTrue(alerts.informAlerts.isEmpty)
    }
    
    func test_shouldRemoveAlertFromInformAlertsOfOne() {
        
        let alert = makeInformAlert()
        var alerts = makeSUT(informAlerts: [alert])
        XCTAssertNoDiff(alerts.informAlerts, [alert])
        
        alerts.next()
        
        XCTAssertTrue(alerts.informAlerts.isEmpty)
    }
    
    func test_shouldRemoveFirstAlertFromInformAlertsOfTwo() {
        
        let (first, second) = (makeInformAlert(), makeInformAlert())
        XCTAssertNotEqual(first, second)
        var alerts = makeSUT(informAlerts: [first, second])
        XCTAssertNoDiff(alerts.informAlerts, [first, second])
        
        alerts.next()
        
        XCTAssertNoDiff(alerts.informAlerts, [second])
    }
    
    func test_shouldRemoveBothAlertsFromInformAlertsOfTwo() {
        
        let (first, second) = (makeInformAlert(), makeInformAlert())
        XCTAssertNotEqual(first, second)
        var alerts = makeSUT(informAlerts: [first, second])
        XCTAssertNoDiff(alerts.informAlerts, [first, second])
        
        alerts.next()
        alerts.next()
        
        XCTAssertTrue(alerts.informAlerts.isEmpty)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = ClientInformAlerts
    
    private func makeSUT(
        id: UUID = .init(),
        informAlerts: [SUT.InformAlert] = [],
        updateAlert: SUT.UpdateAlert? = nil
    ) -> SUT {
        
        return .init(id: id, informAlerts: informAlerts, updateAlert: updateAlert)
    }
    
    private func makeInformAlert(
        id: UUID = .init(),
        title: String = anyMessage(),
        text: String = anyMessage()
    ) -> SUT.InformAlert {
        
        return .init(id: id, title: title, text: text)
    }
    
    private func makeUpdateAlert(
        id: UUID = .init(),
        title: String = anyMessage(),
        text: String = anyMessage(),
        link: String? = nil,
        version: String? = nil,
        actionType: ClientInformActionType = .optional
    ) -> SUT.UpdateAlert {
        
        return .init(id: id, title: title, text: text, link: link, version: version, actionType: actionType)
    }
}
