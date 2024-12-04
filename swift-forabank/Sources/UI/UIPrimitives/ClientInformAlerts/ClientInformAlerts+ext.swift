//
//  ClientInformAlerts+ext.swift
//  ForaBank
//
//  Created by Nikolay Pochekuev on 06.11.2024.
//

import Foundation
import SwiftUI

public enum ClientInformActionType: String {
    
    case required
    case optional
    case authBlocking
    
    public init?(updateType: String) {
        
        guard let type = ClientInformActionType(rawValue: updateType) else { return nil }
        self = type
    }
}

public enum AlertModelType: Identifiable {
    
    public var id: UUID {
        switch self {
        case .clientInformAlerts(let alert): return alert.id
        case .alertViewModel(let alert): return alert.id
        }
    }
    
    case clientInformAlerts(ClientInformAlerts.Alert)
    case alertViewModel(Alert.ViewModel)
}

extension ClientInformAlerts {

    public mutating func next() {
            
        if informAlerts.isEmpty {

            if let updateAlert {
                
                self.updateAlert = .init(
                    id: .init(), // Restore with different ID
                    title: updateAlert.title,
                    text: updateAlert.text,
                    link: updateAlert.link,
                    version: updateAlert.version,
                    actionType: updateAlert.actionType
                )
            }
        } else {
            informAlerts = .init(informAlerts.dropFirst())
        }
    }
}
