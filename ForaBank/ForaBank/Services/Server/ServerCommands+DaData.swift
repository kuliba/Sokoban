//
//  ServerCommands+DaData.swift
//  ForaBank
//
//  Created by Дмитрий on 03.02.2022.
//

import Foundation

extension ServerCommands {
    
    enum DaDataController {
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/rest/getPhoneInfo
         */
        struct GetPhoneInfo: ServerCommand {

            let token: String?
            let endpoint = "/rest/getPhoneInfo"
            let method: ServerCommandMethod = .post
            let parameters: [ServerCommandParameter]? = nil
            let payload: Payload?
            let timeout: TimeInterval? = nil
            
            struct Payload: Encodable {
                
                let phoneNumbersList: [String]
            }
            
            struct Response: ServerResponse {

                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: [DaDataPhoneData]?
            }
            
            internal init(token: String, payload: Payload) {

                self.token = token
                self.payload = payload
            }
        }
    }
}
