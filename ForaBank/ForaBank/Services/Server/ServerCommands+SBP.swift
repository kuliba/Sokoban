//
//  ServerCommands+SBP.swift
//  ForaBank
//
//  Created by Max Gribov on 30.01.2023.
//

import Foundation
import ServerAgent

extension ServerCommands {
    
    enum SBPController {
    
        /*
         https://pl.forabank.ru/dbo/api/v3/swagger-ui/index.html#/SBPController/getScenarioQRData
         */
        
        struct GetScenarioQRData: ServerCommand {
            
            let token: String
            let endpoint = "/rest/binding/v1/getScenarioQRData"
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
    
    enum SBPPaymentController {
        
        /*
         https://pl.forabank.ru/dbo/api/v3/swagger-ui/index.html#/SBPPaymentController/createC2BPaymentAcc
         */
        
        struct CreateC2BPaymentAcc: ServerCommand {
            
            let token: String
            let endpoint = "/rest/transfer/createC2BPaymentAcc"
            let method: ServerCommandMethod = .post
            let payload: Payload?

            struct Payload: Encodable {
                
                let parameters: [PaymentC2BParameter]
            }
            
            struct Response: ServerResponse {
    
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: PaymentC2BResponseData?
            }
            
            init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
        }
        
        /*
         https://pl.forabank.ru/dbo/api/v3/swagger-ui/index.html#/SBPPaymentController/createC2BPaymentCard
         */
        
        struct CreateC2BPaymentCard: ServerCommand {
            
            let token: String
            let endpoint = "/rest/transfer/createC2BPaymentCard"
            let method: ServerCommandMethod = .post
            let payload: Payload?

            struct Payload: Encodable {
                
                let parameters: [PaymentC2BParameter]
            }
            
            struct Response: ServerResponse {
    
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: PaymentC2BResponseData?
            }
            
            init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
        }
    }
}
