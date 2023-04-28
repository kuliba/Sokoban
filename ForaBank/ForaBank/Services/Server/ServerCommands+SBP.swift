//
//  ServerCommands+SBP.swift
//  ForaBank
//
//  Created by Max Gribov on 30.01.2023.
//

import Foundation

extension ServerCommands {
    
    enum SBPController {
    
        /*
         http://10.1.206.21:8080/swagger-ui/index.html#/SBPController/getScenarioQRData
         */
        
        struct GetScenarioQRData: ServerCommand {
            
            let token: String
            let endpoint = "/rest/transfer/getScenarioQRData"
            let method: ServerCommandMethod = .post
            let payload: Payload?

            struct Payload: Encodable {
                
                let QRLink: String
            }
            
            struct Response: ServerResponse {
    
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: QRScenarioData?
            }
            
            init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
        }
    }
}
