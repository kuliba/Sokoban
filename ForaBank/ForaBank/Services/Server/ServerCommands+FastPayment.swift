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
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/rest/createFastPaymentContract
         */
        struct CreateFastPaymentContract: ServerCommand {
            
            let token: String
            let endpoint = "/rest/createFastPaymentContract"
            let method: ServerCommandMethod = .post
            let parameters: [ServerCommandParameter]? = nil
            let payload: PayloadFastPayment?
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: EmptyData?
            }
            
            internal init(token: String, payload: PayloadFastPayment) {
                
                self.token = token
                self.payload = payload
            }
        }
        
        /*
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/rest/fastPaymentContractFindList
         */
        struct FastPaymentContractFindList: ServerCommand {
            
            let token: String
            let endpoint = "/rest/fastPaymentContractFindList"
            let method: ServerCommandMethod = .get
            let parameters: [ServerCommandParameter]? = nil
            let payload: Payload? = nil

            struct Payload: Encodable {}
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: [FastPaymentContractFullInfoType]?
                
                struct FastPaymentContractFullInfoType: Decodable, Equatable {
                    
                    let fastPaymentContractAccountAttributeList: [FastPaymentContractAccountAttributeTypeData]?
                    let fastPaymentContractAttributeList: [FastPaymentContractAttributeTypeData]?
                    let fastPaymentContractClAttributeList: [FastPaymentContractClAttributeTypeData]?
                }
            }
            
            internal init(token: String) {
                
                self.token = token
            }
        }
        
        /*
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/rest/updateFastPaymentContract
         */
        struct UpdateFastPaymentContract: ServerCommand {
            
            let token: String
            let endpoint = "/rest/updateFastPaymentContract"
            let method: ServerCommandMethod = .post
            let parameters: [ServerCommandParameter]? = nil
            let payload: PayloadFastPayment?
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: EmptyData?
            }
            
            internal init(token: String, payload: PayloadFastPayment) {
                
                self.token = token
                self.payload = payload
            }
        }
        
        struct PayloadFastPayment: Encodable {
            
            let accountId: Int?
            let cardId: Int?
            let contractId: Int?
            let flagBankDefault: FastPaymentFlag
            let flagClientAgreementIn: FastPaymentFlag
            let flagClientAgreementOut: FastPaymentFlag
        }
    }
}

