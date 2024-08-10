//
//  ServiceFailureAlert.ServiceFailure+ext.swift
//  ForaBank
//
//  Created by Igor Malyarov on 10.08.2024.
//

import SwiftUI
import UIPrimitives

extension ServiceFailureAlert.ServiceFailure: Identifiable {
    
    var id: ID {
        
        switch self {
        case .connectivityError: return .connectivity
        case .serverError:       return .server
        }
    }
    
    enum ID: Hashable {
        
        case connectivity, server
    }
}

extension ServiceFailureAlert.ServiceFailure {
    
    func alert<Event>(
        connectivityErrorTitle: String = "",
        connectivityErrorMessage: String,
        serverErrorTitle: String = "Ошибка",
        event: @escaping (Event) -> Void,
        map: @escaping (ServiceFailureEvent) -> Event
    ) -> Alert {
        
        self.alert(
            connectivityErrorTitle: connectivityErrorTitle,
            connectivityErrorMessage: connectivityErrorMessage,
            serverErrorTitle: serverErrorTitle,
            event: { event(map($0)) }
        )
    }
    
    enum ServiceFailureEvent {
        
        case dismissAlert
    }
    
    private func alert(
        connectivityErrorTitle: String = "",
        connectivityErrorMessage: String,
        serverErrorTitle: String = "Ошибка",
        event: @escaping (ServiceFailureEvent) -> Void
    ) -> Alert {
        
        switch self {
        case .connectivityError:
            let model = alertModelOf(
                title: connectivityErrorTitle,
                message: connectivityErrorMessage
            )
            return .init(with: model, event: event)
            
        case let .serverError(message):
            let model = alertModelOf(
                title: serverErrorTitle,
                message: message
            )
            return .init(with: model, event: event)
        }
    }
    
    private func alertModelOf(
        title: String,
        message: String? = nil
    ) -> AlertModelOf<ServiceFailureEvent> {
        
        return .init(
            title: title,
            message: message,
            primaryButton: .init(
                type: .default,
                title: "OK",
                event: .dismissAlert
            )
        )
    }
}
