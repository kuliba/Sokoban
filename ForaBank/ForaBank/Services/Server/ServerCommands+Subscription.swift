//
//  ServerCommands+Subscription.swift
//  ForaBank
//
//  Created by Max Gribov on 30.01.2023.
//

import Foundation
import ServerAgent

extension ServerCommands {
    
    enum SubscriptionController {
        
        /*
         https://pl.forabank.ru/dbo/api/v3/swagger-ui/index.html#/SubscriptionController/ConfirmC2BSubAcc
         */
        
        struct ConfirmC2BSubAcc: ServerCommand {
            
            let token: String
            let endpoint = "/rest/binding/v2/ConfirmC2BSubAcc"
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
            let endpoint = "/rest/binding/v2/ConfirmC2BSubCard"
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
            let endpoint = "/rest/binding/v2/DeniedC2BSubscription"
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
        
        /*
         http://10.1.206.21:8080/swagger-ui/index.html#/SubscriptionController/deniedC2BSubscription
         */
        
        struct GetC2bSubscriptions: ServerCommand {
            
            let token: String
            let endpoint = "/rest/binding/v1/getC2BSub"
            let method: ServerCommandMethod = .post
            let payload: Payload?

            struct Payload: Encodable {}
            
            struct Response: ServerResponse {
    
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: C2BSubscription?
            }
            
            init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
        }
        
        /*
         https://pl.forabank.ru/dbo/api/v3/swagger-ui/index.html#/SubscriptionController/getDetailC2BSub
         */
        
        struct GetC2bDetailSubscriptions: ServerCommand {
            
            let token: String
            let endpoint = "/rest/binding/v2/getDetailC2BSub"
            let method: ServerCommandMethod = .post
            let payload: Payload?

            struct Payload: Encodable {
                
                let subscriptionToken: String
            }
            
            struct Response: ServerResponse {
    
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: BaseScenarioQrParameter?
            }
            
            init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
        }
        
        /*
         https://pl.forabank.ru/dbo/api/v3/swagger-ui/index.html#/SubscriptionController/cancelC2BSub
         */
        
        struct CancelC2bSubscriptions: ServerCommand {
            
            let token: String
            let endpoint = "/rest/binding/v2/cancelC2BSub"
            let method: ServerCommandMethod = .post
            let payload: Payload?

            struct Payload: Encodable {
                
                let subscriptionToken: String
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
         https://pl.forabank.ru/dbo/api/v3/swagger-ui/index.html#/SubscriptionController/updateC2BSubCard
         */
        
        struct UpdateC2bSubscriptionCard: ServerCommand {
            
            let token: String
            let endpoint = "/rest/binding/v2/updateC2BSubCard"
            let method: ServerCommandMethod = .post
            let payload: Payload?

            struct Payload: Encodable {
                
                let subscriptionToken: String
                let productId: Int
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
         https://pl.forabank.ru/dbo/api/v3/swagger-ui/index.html#/SubscriptionController/updateC2BSubCard
         */
        
        struct UpdateC2bSubscriptionAcc: ServerCommand {
            
            let token: String
            let endpoint = "/rest/binding/v2/updateC2BSubAcc"
            let method: ServerCommandMethod = .post
            let payload: Payload?

            struct Payload: Encodable {
                
                let subscriptionToken: String
                let productId: Int
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
