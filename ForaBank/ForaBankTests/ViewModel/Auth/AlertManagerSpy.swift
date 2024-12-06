//
//  AlertManagerSpy.swift
//  ForaBankTests
//
//  Created by Nikolay Pochekuev on 02.12.2024.
//

import Combine
@testable import ForaBank

final class AlertManagerSpy {
    
    typealias Alert = ClientInformAlerts
    
    private let subject = PassthroughSubject<Alert?, Never>()
    private(set) var dismissCount = 0
    private(set) var updates = [Alert]()
    
    var updatesCount: Int { updates.count }
}

extension AlertManagerSpy: AlertManager {
    
    var alertPublisher: AnyPublisher<Alert?, Never> {
        
        subject.eraseToAnyPublisher()
    }
    
    func emit(_ alerts: Alert?) {
        
        subject.send(alerts)
    }

    func dismiss() {
        
        dismissCount += 0
    }
    
    func dismissAll() {
        
    }
    
    func update(alerts: Alert) {
        
        updates.append(alerts)
    }
}
