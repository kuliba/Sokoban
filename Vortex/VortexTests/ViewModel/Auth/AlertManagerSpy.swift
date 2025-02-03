//
//  AlertManagerSpy.swift
//  VortexTests
//
//  Created by Nikolay Pochekuev on 02.12.2024.
//

import Combine
@testable import Vortex

final class AlertManagerSpy {
    
    typealias Alert = ClientInformAlerts
    
    private let subject = PassthroughSubject<Alert?, Never>()
    private let isUpdateAllowedSubject = CurrentValueSubject<Bool, Never>(true)

    private(set) var dismissCount = 0
    private(set) var updates = [Alert]()
    
    var updatesCount: Int { updates.count }
}

extension AlertManagerSpy: AlertManager {
    
    var updatePermissionPublisher: AnyPublisher<Bool, Never> {
        isUpdateAllowedSubject.eraseToAnyPublisher()
    }
    
    func setUpdatePermission(_ shouldUpdate: Bool) {
        isUpdateAllowedSubject.send(shouldUpdate)
    }
    
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
        dismissCount += 1
    }
    
    func update(alerts: Alert) {
        
        updates.append(alerts)
    }
}
