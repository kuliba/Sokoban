//
//  AlertManager.swift
//  Vortex
//
//  Created by Nikolay Pochekuev on 27.11.2024.
//

import Combine
import Foundation

protocol AlertManager<Alert> {
    
    associatedtype Alert
    
    var alertPublisher: AnyPublisher<Alert?, Never> { get }
    var updatePermissionPublisher: AnyPublisher<Bool, Never> { get }
    func setUpdatePermission(_ shouldUpdate: Bool)
    func dismiss()
    func dismissAll()
    func update(alerts: ClientInformAlerts)
}

final class NotAuthorizedAlertManager {
    
    typealias Alert = ClientInformAlerts
    
    private let subject: CurrentValueSubject<ClientInformAlerts?, Never>
    private let isUpdateAllowedSubject = CurrentValueSubject<Bool, Never>(true)

    init(
        alerts: ClientInformAlerts? = nil
    ) {
        subject = .init(alerts)
    }
}

extension NotAuthorizedAlertManager: AlertManager {
    
    var alertPublisher: AnyPublisher<Alert?, Never> {
        
        subject
            .map { $0 }
            .eraseToAnyPublisher()
    }

    var updatePermissionPublisher: AnyPublisher<Bool, Never> { 
        
        isUpdateAllowedSubject.eraseToAnyPublisher()
    }

    func setUpdatePermission(_ shouldUpdate: Bool) {
       
        isUpdateAllowedSubject.send(shouldUpdate)
    }
    
    func dismiss() {
        
        guard var currentValue = subject.value else { return }
        currentValue.next()
        subject.send(currentValue)
    }
    
    func dismissAll() {
        
        subject.value = nil
    }
    
    func update(alerts: ClientInformAlerts) {
        
        subject.send(alerts)
    }
}
