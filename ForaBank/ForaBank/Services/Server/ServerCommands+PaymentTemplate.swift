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
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/PaymentTemplateController/deletePaymentTemplatesUsingDELETE
         */
        struct DeletePaymentTemplates: ServerCommand {

            let endpoint = "/rest/deletePaymentTemplates"
            let method: ServerCommandMethod = .delete
            let payload: Payload?
            let token: String?
            
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
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/PaymentTemplateController/getPaymentTemplateListUsingGET
         */
        struct GetPaymentTemplateList: ServerCommand {
            
            let endpoint = "/rest/getPaymentTemplateList"
            let method: ServerCommandMethod = .get
            let payload: Payload? = nil
            let token: String?
            
            struct Payload: Encodable {}
            
            struct Response: ServerResponse {

                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: [PaymentTemplate]
            }
            
            internal init(token: String) {
                
                self.token = token
            }
        }
        
        /*
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/PaymentTemplateController/savePaymentTemplateUsingPOST
         */
        struct SavePaymentTemplate: ServerCommand {
            
            let endpoint = "/rest/savePaymentTemplate"
            let method: ServerCommandMethod = .post
            let payload: Payload?
            let token: String?
            
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
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/PaymentTemplateController/sortingPaymentTemplatesUsingPOST
         */
        struct SortingPaymentTemplates: ServerCommand {
            
            let endpoint = "/rest/sortingPaymentTemplates"
            let method: ServerCommandMethod = .post
            let payload: Payload?
            let token: String?
            
            struct Payload: Encodable {
                
                let sortDataList: [PaymentTemplate.SortData]
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
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/PaymentTemplateController/updatePaymentTemplateUsingPOST
         */
        struct UpdatePaymentTemplate: ServerCommand{
            
            let endpoint = "/rest/updatePaymentTemplate"
            let method: ServerCommandMethod = .post
            let payload: Payload?
            let token: String?
            
            struct Payload: Encodable {
                
                let name: String
                let parameterList: [TransferAbstract]
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
