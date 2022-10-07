//
//  ServerCommand+Sbp.swift
//  ForaBank
//
//  Created by Дмитрий on 30.08.2022.
//

import Foundation

extension ServerCommands {
    
    enum SbpPayController {
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/rest/registerTokenIntentID
         */
        
        struct RegisterToken: ServerCommand {
            
            let token: String
            let endpoint = "/sbpay/registerTokenIntentID"
            let method: ServerCommandMethod = .post
            let payload: Payload?

            struct Payload: Encodable {
                
                let tokenIntentId: String
            }
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: EmptyData?
            }
            
            init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
        }
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/rest/processTokenIntent
         */
        
        struct ProcessToken: ServerCommand {
            
            let token: String
            let endpoint = "/sbpay/processTokenIntent"
            let method: ServerCommandMethod = .post
            let payload: Payload?

            struct Payload: Encodable {
                
                let tokenIntentId: String
                let accountId: String?
                let status: Result
            }
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: Result?
            }
            
            init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
        }
        
        enum Result: String, Codable {
            
            case success = "success"
            case failed = "failed"
        }
    }
}
