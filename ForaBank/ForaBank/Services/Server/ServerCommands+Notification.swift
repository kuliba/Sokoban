//
//  ServerCommands+Notification.swift
//  ForaBank
//
//  Created by Max Gribov on 03.02.2022.
//

import Foundation

extension ServerCommands {
    
    enum NotificationController {

        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/NotificationController/changeNotificationStatus
         */
        struct ChangeNotificationStatus: ServerCommand {

            let token: String?
            let endpoint = "/notification/changeNotificationStatus"
            let method: ServerCommandMethod = .post
            let parameters: [ServerCommandParameter]? = nil
            let payload: Payload?
            let timeout: TimeInterval? = nil

            struct Payload: Encodable {
                
                let eventId: String
                let cloudId: String
                let status: NotificationStatus
            }
            
            struct Response: ServerResponse {

                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: EmptyData?
            }
            
            internal init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
        }
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/NotificationController/getNotificationsUsingGET
         */
        struct GetNotifications: ServerCommand {

            let token: String?
            let endpoint = "/rest/getNotifications"
            let method: ServerCommandMethod = .get
            let parameters: [ServerCommandParameter]?
            let payload: Payload? = nil
            let timeout: TimeInterval? = nil
            
            struct Payload: Encodable {}
            
            struct Response: ServerResponse {

                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: [NotificationData]?
            }
            
            internal init(token: String, offset: Int?, limit: Int?, types: [NotificationData.Kind], states: [NotificationData.State]) {
                
                self.token = token
                var parameters = [ServerCommandParameter]()
                
                if let offset = offset {
                    
                    parameters.append(.init(name: "offset", value: "\(offset)"))
                }
                
                if let limit = limit {
                    
                    parameters.append(.init(name: "limit", value: "\(limit)"))
                }
                // [SEND, PUSH, MAIL]
                let typesParameters = types.map {ServerCommandParameter(name: "notificationType", value: $0.rawValue) }
                parameters.append(contentsOf: typesParameters)
                
                let stateParameters = states.map {ServerCommandParameter(name: "notificationState", value: $0.rawValue) }
                
                parameters.append(contentsOf: stateParameters)
                
                self.parameters = parameters
            }
        }
    }
}
