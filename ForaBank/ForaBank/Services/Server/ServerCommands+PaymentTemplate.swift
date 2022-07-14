//
//  ServerCommand+PaymentTemplate.swift
//  ForaBank
//
//  Created by Max Gribov on 20.12.2021.
//

import Foundation

enum ServerCommands {
    
    enum PaymentTemplateController {
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/PaymentTemplateController/deletePaymentTemplatesUsingDELETE
         */
        struct DeletePaymentTemplates: ServerCommand {
            
            let token: String
            let endpoint = "/rest/deletePaymentTemplates"
            let method: ServerCommandMethod = .delete
            let payload: Payload?
            
            struct Payload: Encodable {
                
                let paymentTemplateIdList: [Int]
            }
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: EmptyData
            }
            
            internal init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
        }
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/PaymentTemplateController/getPaymentTemplateListUsingGET
         */
        struct GetPaymentTemplateList: ServerCommand {
            
            let token: String
            let endpoint = "/rest/getPaymentTemplateList"
            let method: ServerCommandMethod = .get
            
            struct Payload: Encodable {}
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: [PaymentTemplateData]?
            }
            
            internal init(token: String) {
                
                self.token = token
            }
        }
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/PaymentTemplateController/savePaymentTemplateUsingPOST
         */
        struct SavePaymentTemplate: ServerCommand {
            
            let token: String
            let endpoint = "/rest/savePaymentTemplate"
            let method: ServerCommandMethod = .post
            let payload: Payload?
            
            struct Payload: Encodable {
                
                let name: String
                let paymentOperationDetailId: Int
            }
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: Data
                
                struct Data: Decodable, Equatable {
                    
                    let paymentTemplateId: Int
                }
            }
            
            internal init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
        }
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/PaymentTemplateController/sortingPaymentTemplatesUsingPOST
         */
        struct SortingPaymentTemplates: ServerCommand {
            
            let token: String
            let endpoint = "/rest/sortingPaymentTemplates"
            let method: ServerCommandMethod = .post
            let payload: Payload?
            
            struct Payload: Encodable {
                
                let sortDataList: [PaymentTemplateData.SortData]
            }
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: EmptyData
            }
            
            internal init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
        }
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/PaymentTemplateController/updatePaymentTemplateUsingPOST
         */
        struct UpdatePaymentTemplate: ServerCommand{
            
            let token: String
            let endpoint = "/rest/updatePaymentTemplate"
            let method: ServerCommandMethod = .post
            let payload: Payload?
            
            struct Payload: Encodable {
                
                let name: String?
                let parameterList: [TransferData]?
                let paymentTemplateId: Int
            }
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: EmptyData
            }
            
            internal init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
        }
    }
}
