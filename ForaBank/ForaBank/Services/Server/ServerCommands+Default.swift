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
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/default/login.doUsingPOST
         */
        struct Login: ServerCommand {

            let token: String
            let endpoint = "/login.do"
            let method: ServerCommandMethod = .post
            let parameters: [ServerCommandParameter]? = nil
            let payload: Payload? = nil
            
            struct Payload: Encodable {}
            
            struct Response: ServerResponse {

                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: EmptyData?
            }
            
            internal init(token: String) {
                
                self.token = token
            }
        }
    }
}
