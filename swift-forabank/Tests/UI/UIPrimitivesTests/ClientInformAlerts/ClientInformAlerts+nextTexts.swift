//
//  ClientInformAlerts+nextTexts.swift
//
//
//  Created by Igor Malyarov on 28.11.2024.
//

import UIPrimitives
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
    
    // MARK: - UpdateAlert

    func test_shouldNotChangeNilUpdateAlert() {
        
        var alerts = makeSUT(updateAlert: nil)
        XCTAssertNil(alerts.updateAlert)
        
        alerts.next()
        
        XCTAssertNil(alerts.updateAlert)
    }
    
    func test_shouldChangeIDForUpdateAlert() {
        
        let alert = makeUpdateAlert()
        var alerts = makeSUT(updateAlert: alert)
        XCTAssertNotNil(alerts.updateAlert)
        
        alerts.next()
        
        XCTAssertNotEqual(alerts.updateAlert?.id, alert.id)
        XCTAssertNoDiff(alerts.updateAlert?.title, alert.title)
        XCTAssertNoDiff(alerts.updateAlert?.text, alert.text)
        XCTAssertNoDiff(alerts.updateAlert?.link, alert.link)
        XCTAssertNoDiff(alerts.updateAlert?.version, alert.version)
        XCTAssertNoDiff(alerts.updateAlert?.actionType, alert.actionType)
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
