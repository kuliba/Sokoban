//
//  ServerCommands+Subscription.swift
//  ForaBank
//
//  Created by Max Gribov on 30.01.2023.
//

import Foundation

extension ServerCommands {
    
    enum SubscriptionController {
        
        /*
         http://10.1.206.21:8080/swagger-ui/index.html#/SubscriptionController/confirmC2BSubscription
         */
        
        struct ConfirmC2BSubscription: ServerCommand {
            
            let token: String
            let endpoint = "/rest/Subscription/ConfirmC2BSubscription"
            let method: ServerCommandMethod = .post
            let payload: Payload?

            struct Payload: Encodable {
                
                let qrcId: String
                let cardId: String?
                let accountId: String?
            }
            
            struct Response: ServerResponse {
    
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: C2BSubscriptionData?
            }
            
            init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
        }
        
        /*
         http://10.1.206.21:8080/swagger-ui/index.html#/SubscriptionController/deniedC2BSubscription
         */
        
        struct DeniedC2BSubscription: ServerCommand {
            
            let token: String
            let endpoint = "/rest/Subscription/DeniedC2BSubscription"
            let method: ServerCommandMethod = .post
            let payload: Payload?

            struct Payload: Encodable {
                
                let qrcId: String
            }
            
            struct Response: ServerResponse {
    
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: C2BSubscriptionData?
            }
            
            init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
        }
    }
}
