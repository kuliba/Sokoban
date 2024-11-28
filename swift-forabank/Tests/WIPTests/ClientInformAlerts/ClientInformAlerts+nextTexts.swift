//
//  ClientInformAlerts+nextTexts.swift
//
//
//  Created by Igor Malyarov on 28.11.2024.
//

import XCTest

final class ClientInformAlerts_nextTexts: XCTestCase {
    
    func test_shouldNotChangeEmptyInformAlerts() {
        
        var alerts = makeSUT(informAlerts: [])
        XCTAssertTrue(alerts.informAlerts.isEmpty)
        
        alerts.next()
        
        XCTAssertTrue(alerts.informAlerts.isEmpty)
    }
    
    // MARK: - Helpers
    
    func makeSUT(
        id: UUID = .init(),
        informAlerts: [ClientInformAlerts.InformAlert],
        updateAlert: ClientInformAlerts.UpdateAlert? = nil
    ) -> ClientInformAlerts {
        
        return .init(id: id, informAlerts: informAlerts, updateAlert: updateAlert)
    }
}
