//
//  ClientInformAlerts+ext.swift
//  ForaBank
//
//  Created by Nikolay Pochekuev on 06.11.2024.
//

import Foundation

import SwiftUI

enum ClientInformActionType: String {
    case required
    case optional
    case notRequired = "not_required"
}

enum AlertType: Identifiable {
    
    var id: UUID {
        switch self {
        case .clientInformAlerts(let alert): return alert.id
        case .alertViewModel(let viewModelAlert): return viewModelAlert.id
        }
    }
    
    case clientInformAlerts(ClientInformAlerts.Alert)
    case alertViewModel(Alert.ViewModel)
}

extension ClientInformAlerts {
    
    mutating func dropFirst() {
        
        if notRequired.isEmpty {
            
            required = nil
        } else {
            
            notRequired = .init(notRequired.dropFirst())
        }
    }
    
    mutating func showAgain(requiredAlert: ClientInformAlerts.RequiredAlert) {
        guard let alert = alert,
              alert.isRequired || alert.authBlocking else { return }
        required = .init(
            title: requiredAlert.title,
            text: requiredAlert.text,
            type: requiredAlert.type,
            link: requiredAlert.link,
            version: requiredAlert.version,
            authBlocking: requiredAlert.authBlocking
        )
    }
}

extension ClientInformAlerts.Alert {
    
    func swiftUIAlert(action: @escaping (ClientInformActionType) -> Void) -> SwiftUI.Alert {
            let actionType: ClientInformActionType = type

            switch actionType {
            case .required:
                return Alert(
                    title: Text(title),
                    message: Text(text),
                    dismissButton: .default(Text("Обновить"), action: { action(.required) })
                )
            
            case .optional:
                return Alert(
                    title: Text(title),
                    message: Text(text),
                    primaryButton: .cancel(Text("Позже")),
                    secondaryButton: .default(Text("Обновить"), action: { action(.optional) })
                )
            
            case .notRequired:
                return Alert(
                    title: Text(title),
                    message: Text(text),
                    dismissButton: .default(Text("Ok"), action: {
                        action(.notRequired)
                    })
                )
            }
        }
}
