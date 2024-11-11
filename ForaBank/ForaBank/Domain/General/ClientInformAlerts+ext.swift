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
    
    mutating func showAgain(blockingAlert: ClientInformAlerts.Alert) {
        
        guard let alert = alert else { return }
        
        required = .init(
            title: blockingAlert.title,
            text: blockingAlert.text,
            type: blockingAlert.type,
            link: blockingAlert.link,
            version: blockingAlert.version,
            authBlocking: blockingAlert.authBlocking
        )
    }
}

extension ClientInformAlerts.Alert {

    func swiftUIAlert(action: @escaping (ClientInformActionType) -> Void) -> SwiftUI.Alert {
        
        let actionType: ClientInformActionType = type
        let linkableText = url != nil ? "\(text) \(url!)" : text
        
        switch actionType {
        case .required:
            return Alert(
                title: Text(title),
                message: Text(linkableText),
                dismissButton: .default(Text("Обновить"), action: { action(.required) })
            )
            
        case .optional:
            return Alert(
                title: Text(title),
                message: Text(linkableText),
                primaryButton: .cancel(Text("Позже")),
                secondaryButton: .default(Text("Обновить"), action: { action(.optional) })
            )
            
        case .notRequired:
            return Alert(
                title: Text(title),
                message: Text(linkableText),
                dismissButton: .default(Text("Ok"), action: { action(.notRequired) })
            )
        }
    }
}
