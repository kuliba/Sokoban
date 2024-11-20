//
//  Alerts.swift
//  ForaBank
//
//  Created by Nikolay Pochekuev on 29.10.2024.
//

import Foundation

struct ClientInformAlerts {
    
    let id = UUID()

    var informAlert: [InformAlert] = []
    var updateAlert: UpdateAlert?
    
    var alert: Alert? {
        
        informAlert.first?.alert ?? updateAlert?.alert
    }
    
    struct UpdateAlert: Identifiable {
        
        let id = UUID()
        let title: String
        let text: String
        let link: String?
        let version: String?
        let actionType: ClientInformActionType
        
        var alert: Alert {
            return actionType == .required ? .required(self) : .optionalRequired(self)
        }
    }
    
    struct InformAlert: Identifiable {
        
        let id = UUID()
        let title: String
        let text: String
        
        var alert: Alert { .inform(self) }
    }
    
    enum Alert: Identifiable {
        
        case inform(InformAlert)
        case optionalRequired(UpdateAlert)
        case required(UpdateAlert)
        
        var id: UUID {
            
            switch self {
            case let .inform(notRequired):
                return notRequired.id
                
            case let .optionalRequired(optionalRequired):
                return optionalRequired.id
            
            case let .required(required):
                return required.id
            }
        }
    }
}
