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
            let endpoint = "/csrf"
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
                let data: Bool?
            }
            
            internal init(token: String) {
                
                self.token = token
            }
        }
        
        /*
         http://10.1.206.21:8080/swagger-ui/index.html#/CwfLeadController/createLead
         */
        struct CreateLead: ServerCommand {
            
            let token: String
            let endpoint = "/lead/createLead"
            let method: ServerCommandMethod = .post
            let payload: Payload?
            
            struct Payload: Encodable {
                
                let firstName: String
                let phone: String
                let device: String
                let os: String
                let cardTarif: Int
                let cardType: Int
            }
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let data: OrderLeadData?
                let errorMessage: String?
            }
            
            internal init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
        }
        
        /*
         http://10.1.206.21:8080/swagger-ui/index.html#/CwfLeadController/verifyPhone
         */
        struct VerifyPhone: ServerCommand {
            
            let token: String
            let endpoint = "/lead/verifyPhone"
            let method: ServerCommandMethod = .post
            let payload: Payload?
            
            struct Payload: Encodable {
                
                let leadID: String
                let smsCode: String
            }
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let data: EmptyData?
                let errorMessage: String?
            }
            
            internal init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
        }
        
        /*
         http://10.1.206.21:8080/swagger-ui/index.html#/DictionaryController/getJsonAbroad
        */
        struct GetJsonAbroad: ServerCommand {
            
            let token: String
            let endpoint = "/dict/getJsonAbroad"
            let method: ServerCommandMethod = .get
            let parameters: [ServerCommandParameter]?
            
            struct Payload: Encodable {}
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: TransferAbroadResponseData?
            }
            
            init(token: String, serial: String?) {
                
                self.token = token
                
                if let serial = serial {
                    
                    var parameters = [ServerCommandParameter]()
                    parameters.append(.init(name: "serial", value: serial))
                    self.parameters = parameters
                    
                } else {
                    
                    self.parameters = nil
                }
            }
        }
    }
}

