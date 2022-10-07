//
//  ServerCommands+FastPayment.swift
//  ForaBank
//
//  Created by Дмитрий on 24.01.2022.
//

import Foundation
import SwiftUI

extension ServerCommands {
    
    enum FastPaymentController {
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/rest/createFastPaymentContract
         */
        struct CreateFastPaymentContract: ServerCommand {
            
            let token: String
            let endpoint = "/rest/createFastPaymentContract"
            let method: ServerCommandMethod = .post
            let payload: BasePayload?
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: EmptyData?
            }
            
            internal init(token: String, payload: BasePayload) {
                
                self.token = token
                self.payload = payload
            }
        }
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/rest/fastPaymentContractFindList
         */
        struct FastPaymentContractFindList: ServerCommand {
            
            let token: String
            let endpoint = "/rest/fastPaymentContractFindList"
            let method: ServerCommandMethod = .get
            
            struct Payload: Encodable {}
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: [FastPaymentContractFullInfoType]?
            }
            
            internal init(token: String) {
                
                self.token = token
            }
        }
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/rest/updateFastPaymentContract
         */
        struct UpdateFastPaymentContract: ServerCommand {
            
            let token: String
            let endpoint = "/rest/updateFastPaymentContract"
            let method: ServerCommandMethod = .post
            let payload: BasePayload?
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: EmptyData?
            }
            
            internal init(token: String, payload: BasePayload) {
                
                self.token = token
                self.payload = payload
            }
        }
        
        struct BasePayload: Encodable {
            
            let accountId: Int?
            let cardId: Int?
            let contractId: Int?
            let flagBankDefault: FastPaymentFlag
            let flagClientAgreementIn: FastPaymentFlag
            let flagClientAgreementOut: FastPaymentFlag
        }
    }
}

