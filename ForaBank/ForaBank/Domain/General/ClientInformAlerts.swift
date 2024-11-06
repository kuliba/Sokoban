//
//  Alerts.swift
//  ForaBank
//
//  Created by Nikolay Pochekuev on 29.10.2024.
//

import Foundation

struct ClientInformAlerts {
    
    var notRequired: [NotRequiredAlert] = []
    var required: RequiredAlert?
    
    var alert: Alert? {
        
        notRequired.first?.alert ?? required?.alert
    }
    
    struct RequiredAlert: Identifiable {
        
        let id = UUID()
        let title: String
        let text: String
        let type: ClientInformActionType
        let link: String?
        let version: String?
        let authBlocking: Bool
        
        
        var alert: Alert {
            .init(
                id: id,
                isRequired: true, 
                type: type,
                title: title,
                text: text,
                link: link,
                version: version,
                authBlocking: authBlocking
            )
        }
    }
    
    struct NotRequiredAlert: Identifiable {
        
        let id = UUID()
        let title: String
        let text: String
        let authBlocking: Bool
        
        var alert: Alert {
            .init(
                id: id,
                isRequired: false, 
                type: .notRequired,
                title: title,
                text: text,
                link: nil,
                version: nil, 
                authBlocking: authBlocking
            )
        }
    }
    
    struct Alert: Identifiable {
        
        let id: UUID
        let isRequired: Bool
        let type: ClientInformActionType
        let title: String
        let text: String
        let link: String?
        let version: String?
        let authBlocking: Bool
    }
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

import SwiftUI

enum ClientInformActionType: String {
    case required
    case optional
    case notRequired = "not_required"
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
