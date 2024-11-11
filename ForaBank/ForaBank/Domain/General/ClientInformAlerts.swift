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
                text: text.textWithLink(),
                url: text.extractedURL,
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
                text: text.textWithLink(),
                url: text.extractedURL,
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
        let url: URL?
        let link: String?
        let version: String?
        let authBlocking: Bool
    }
}
