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
}

enum AlertType: Identifiable {
    
    var id: UUID {
        switch self {
        case .clientInformAlerts(let alert): return alert.id
        case .alertViewModel(let alert): return alert.id
        }
    }
    
    case clientInformAlerts(ClientInformAlerts.Alert)
    case alertViewModel(Alert.ViewModel)
}

extension ClientInformAlerts {

    mutating func next() {
            
        if informAlert.isEmpty {

            if let updateAlert {
                
//                 Restore with different ID
                self.updateAlert = .init(
                    title: updateAlert.title,
                    text: updateAlert.text,
                    link: updateAlert.link,
                    version: updateAlert.version,
                    actionType: updateAlert.actionType
                )
            }
        } else {
            informAlert = .init(
                informAlert.dropFirst()
            )
        }
    }

    mutating func showAgain(requiredAlert: UpdateAlert) {
       
        updateAlert = .init(
            title: requiredAlert.title,
            text: requiredAlert.text,
            link: requiredAlert.link,
            version: requiredAlert.version,
            actionType: requiredAlert.actionType
        )
    }
}
