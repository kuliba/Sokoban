//
//  ServerCommands+ConsentController.swift
//  ForaBank
//
//  Created by Дмитрий on 20.01.2022.
//

import Foundation

extension ServerCommands {
    
    enum ConsentController {
        
        /*
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/rest/changeClientConsentMe2MePull
         */
        struct ChangeClientConsentMe2MePull: ServerCommand {
            
            let token: String
            let endpoint = "/rest/changeClientConsentMe2MePull"
            let method: ServerCommandMethod = .post
            let parameters: [ServerCommandParameter]? = nil
            let payload: Payload?

            struct Payload: Encodable {
                let bankList: [String]
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
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/rest/createIsOneTimeConsentMe2MePull
         */
        struct CreateIsOneTimeConsentMe2MePull: ServerCommand {
            
            let token: String
            let endpoint = "/rest/createIsOneTimeConsentMe2MePull"
            let method: ServerCommandMethod = .post
            let parameters: [ServerCommandParameter]? = nil
            let payload: Payload?

            struct Payload: Encodable {
                let bankId: String
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
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/rest/createPermanentConsentMe2MePull
         */
        struct CreatePermanentConsentMe2MePull: ServerCommand {
            
            let token: String
            let endpoint = "/rest/createPermanentConsentMe2MePull"
            let method: ServerCommandMethod = .post
            let parameters: [ServerCommandParameter]? = nil
            let payload: Payload?

            struct Payload: Encodable {
                let bankId: String
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
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/rest/getClientConsentMe2MePull
         */
        struct GetClientConsentMe2MePull: ServerCommand {
            
            let token: String
            let endpoint = "/rest/getClientConsentMe2MePull"
            let method: ServerCommandMethod = .get
            let parameters: [ServerCommandParameter]? = nil
            let payload: Payload? = nil

            struct Payload: Encodable {}
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: ConsentMe2MePullResponseData?
            }
            
            internal init(token: String) {
                
                self.token = token
            }
        }
        
        /*
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/rest/getMe2MeDebitConsent
         */
        struct GetMe2MeDebitConsent: ServerCommand {
            
            let token: String
            let endpoint = "/rest/getMe2MeDebitConsent"
            let method: ServerCommandMethod = .post
            let parameters: [ServerCommandParameter]? = nil
            let payload: Payload?

            struct Payload: Encodable {
                let bankId: String
            }
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: Me2MeDebitConsentData?
            }
            
            internal init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
        }
    }
}
