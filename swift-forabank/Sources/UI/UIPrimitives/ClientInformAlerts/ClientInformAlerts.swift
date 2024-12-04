//
//  Alerts.swift
//  ForaBank
//
//  Created by Nikolay Pochekuev on 29.10.2024.
//

import Foundation

public struct ClientInformAlerts: Equatable {
    
    public let id: UUID

    public var informAlerts: [InformAlert] = []
    public var updateAlert: UpdateAlert?
    
    public init(
        id: UUID, 
        informAlerts: [InformAlert], 
        updateAlert: UpdateAlert? = nil
    ) {
        self.id = id
        self.informAlerts = informAlerts
        self.updateAlert = updateAlert
    }
    
    public var alert: Alert? {
        
        informAlerts.first?.alert ?? updateAlert?.alert
    }
    
    public struct UpdateAlert: Equatable, Identifiable {
        
        public let id: UUID
        public let title: String
        public let text: String
        public let link: String?
        public let version: String?
        public let actionType: ClientInformActionType
        
        public init(
            id: UUID, 
            title: String,
            text: String,
            link: String?,
            version: String?,
            actionType: ClientInformActionType
        ) {
            self.id = id
            self.title = title
            self.text = text
            self.link = link
            self.version = version
            self.actionType = actionType
        }
        
        public var alert: Alert {
            
            switch actionType {
            case .required:
                return .required(self)
                
            case .optional:
                return .optionalRequired(self)
                
            case .authBlocking:
                return .required(self)
            }
        }
    }
    
    public struct InformAlert: Equatable, Identifiable {
        
        public let id: UUID
        public let title: String
        public let text: String
        
        public init(
            id: UUID, 
            title: String,
            text: String
        ) {
            self.id = id
            self.title = title
            self.text = text
        }
        
        public var alert: Alert { .inform(self) }
    }
    
    public enum Alert: Identifiable {
        
        case inform(InformAlert)
        case optionalRequired(UpdateAlert)
        case required(UpdateAlert)
        
        public var id: UUID {
            
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
