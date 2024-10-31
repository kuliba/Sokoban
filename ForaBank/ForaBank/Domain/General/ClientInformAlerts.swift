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
        
        var alert: Alert {
            .init(
                id: id,
                isRequired: true,
                title: title,
                text: text
            )
        }
    }
    
    struct NotRequiredAlert: Identifiable {
        
        let id = UUID()
        let title: String
        let text: String
        
        var alert: Alert {
            .init(
                id: id,
                isRequired: false,
                title: title,
                text: text
            )
        }
    }
    
    struct Alert: Identifiable {
        
        let id: UUID
        let isRequired: Bool
        let title: String
        let text: String
    }
}
