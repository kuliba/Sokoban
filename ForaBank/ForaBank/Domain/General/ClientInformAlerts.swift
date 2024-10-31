//
//  Alerts.swift
//  ForaBank
//
//  Created by Nikolay Pochekuev on 29.10.2024.
//

import Foundation

struct ClientInformAlerts {
    
    var notRequered: [NotReuqeredAlert] = []
    var requered: ReuqeredAlert?
    
    var alert: Alert? {
        
        notRequered.first?.alert ?? requered?.alert
    }
    
    struct ReuqeredAlert: Identifiable {
        
        let id = UUID()
        let title: String
        let text: String
        
        var alert: Alert {
            .init(
                id: id,
                isRequered: true,
                title: title,
                text: text
            )
        }
    }
    
    struct NotReuqeredAlert: Identifiable {
        
        let id = UUID()
        let title: String
        let text: String
        
        var alert: Alert {
            .init(
                id: id,
                isRequered: false,
                title: title,
                text: text
            )
        }
    }
    
    struct Alert: Identifiable {
        
        let id: UUID
        let isRequered: Bool
        let title: String
        let text: String
    }
}
