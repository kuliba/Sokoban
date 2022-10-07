//
//  ServerCommands+Default.swift
//  ForaBank
//
//  Created by Max Gribov on 01.02.2022.
//

import Foundation

extension ServerCommands {
    
    enum Default {
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/default/login.doUsingPOST
         */
        struct Login: ServerCommand {
            
            let token: String
            let endpoint = "/login.do"
            let method: ServerCommandMethod = .post
            let payload: Payload?
            
            struct Payload: Encodable {
                
                let cryptoVersion: String?
                let appId: String
                let pushDeviceId: String
                let pushFcmToken: String
                let serverDeviceGUID: String
                let loginValue: String
                let type: String
                let operationSystemVersion: String?
                let appVersion: String?
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
    }
}
