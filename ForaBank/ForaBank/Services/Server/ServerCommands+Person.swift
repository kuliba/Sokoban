//
//  ServerCommands+Person.swift
//  ForaBank
//
//  Created by Дмитрий on 02.02.2022.
//

import Foundation

extension ServerCommands {
    
    enum PersonController {
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/rest/getClientInfo
         */
        struct GetClientInfo: ServerCommand {
            
            let token: String
            let endpoint = "/rest/getClientInfo"
            let method: ServerCommandMethod = .post
            
            struct Payload: Encodable {}
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: ClientInfoData?
            }
            
            internal init(token: String) {
                
                self.token = token
            }
        }
    }
}
