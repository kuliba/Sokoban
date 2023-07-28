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
         https://pl.forabank.ru/dbo/api/v3/swagger-ui/index.html#/SubscriptionController/ConfirmC2BSubAcc
         */
        
        struct ConfirmC2BSubAcc: ServerCommand {
            
            let token: String
            let endpoint = "/rest/binding/v1/ConfirmC2BSubAcc"
            let method: ServerCommandMethod = .post
            let payload: Payload?

            struct Payload: Encodable {
                
                let qrcId: String
                let productId: String
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
         https://pl.forabank.ru/dbo/api/v3/swagger-ui/index.html#/SubscriptionController/сonfirmC2BSubCard
         */
        
        struct ConfirmC2BSubCard: ServerCommand {
            
            let token: String
            let endpoint = "/rest/binding/v1/ConfirmC2BSubCard"
            let method: ServerCommandMethod = .post
            let payload: Payload?

            struct Payload: Encodable {
                
                let qrcId: String
                let productId: String
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
         https://pl.forabank.ru/dbo/api/v3/swagger-ui/index.html#/SubscriptionController/deniedC2BSubscription
         */
        
        struct DeniedC2BSubscription: ServerCommand {
            
            let token: String
            let endpoint = "/rest/binding/v1/DeniedC2BSubscription"
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
