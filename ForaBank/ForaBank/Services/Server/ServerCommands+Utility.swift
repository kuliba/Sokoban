//
//  ServerCommands+Utility.swift
//  ForaBank
//
//  Created by Дмитрий on 19.01.2022.
//

import Foundation

extension ServerCommands {
    
    enum UtilityController {
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/csrf
         */
        struct Csrf: ServerCommand {
            
            let token: String = ""
            let endpoint = "/csrf/"
            let method: ServerCommandMethod = .get
            let cookiesProvider: Bool = true
            
            struct Payload: Encodable {}
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: CsrfData?
            }
        }
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/getSessionTimeout
         */
        struct GetSessionTimeout: ServerCommand {
            
            let token: String
            let endpoint = "/getSessionTimeout"
            let method: ServerCommandMethod = .get
            
            struct Payload: Encodable {}
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: Int?
            }
            
            internal init(token: String) {
                
                self.token = token
            }
        }
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/keyExchange
         */
        struct KeyExchange: ServerCommand {
            
            let token: String
            let endpoint = "/keyExchange"
            let method: ServerCommandMethod = .post
            let payload: Payload?
            
            struct Payload: Encodable {
                
                let data: String
                let token: String
                let type: String
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
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/rest/isLogin
         */
        struct IsLogin: ServerCommand {
            
            let token: String
            let endpoint = "/rest/isLogin"
            let method: ServerCommandMethod = .get
            
            struct Payload: Encodable {}
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: Bool
            }
            
            internal init(token: String) {
                
                self.token = token
            }
        }
    }
}

