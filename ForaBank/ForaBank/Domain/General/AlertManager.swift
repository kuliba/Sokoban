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
    func dismiss()
    func dismissAll()
    func update(alerts: ClientInformAlerts)
}

final class NotAuthorizedAlertManager {
    
    typealias Alert = ClientInformAlerts
    
    private let subject: CurrentValueSubject<ClientInformAlerts?, Never>
    
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
