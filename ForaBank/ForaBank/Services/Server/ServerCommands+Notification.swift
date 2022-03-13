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
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/NotificationController/getNotificationsUsingGET
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
            
            internal init(token: String, offset: Int?, limit: Int?, type: NotificationData.Kind, state: NotificationData.State) {
                
                self.token = token
                var parameters = [ServerCommandParameter]()
                
                if let offset = offset {
                    
                    parameters.append(.init(name: "offset", value: "\(offset)"))
                }
                
                if let limit = limit {
                    
                    parameters.append(.init(name: "limit", value: "\(limit)"))
                }
                
                parameters.append(.init(name: "notificationType", value: type.rawValue))
                parameters.append(.init(name: "notificationState", value: state.rawValue))
                
                self.parameters = parameters
            }
        }
    }
}
