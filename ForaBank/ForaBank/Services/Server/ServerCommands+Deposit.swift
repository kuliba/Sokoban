//
//  ServerCommands+DepositController.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 1/31/22.
//

import Foundation

extension ServerCommands {
    
    enum DepositController {
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/DepositController/getDepositInfoUsingPOST
         */
        struct GetDepositInfo: ServerCommand {
            
            let token: String
            let endpoint = "/rest/getDepositInfo"
            let method: ServerCommandMethod = .post
            let payload: Payload?
            
            struct Payload: Encodable {
                
                let id: ProductData.ID
            }
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: DepositInfoDataItem?
            }
            
            init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
            
            init(token: String, productId: ProductData.ID) {
                
                self.token = token
                self.payload = .init(id: productId)
            }
        }
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/DepositController/getDepositStatementUsingPOST
         */
        struct GetDepositStatement: ServerCommand {
            
            let token: String
            let endpoint = "/rest/getDepositStatement_V2"
            let method: ServerCommandMethod = .post
            let payload: BasePayload?
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: [ProductStatementData]?
            }
            
            internal init(token: String, payload: BasePayload) {
                
                self.token = token
                self.payload = payload
            }
            
            init(token: String, productId: ProductData.ID) {
                
                self.init(token: token, payload: .init(id: productId))
            }
        }
        
        /*
         http://10.1.206.21:8080/swagger-ui/index.html#/DepositController/getDepositStatementForPeriod_V2
         */
        
        //TODO: - tests
        struct GetDepositStatementForPeriod: ServerCommand {
            
            let token: String
            let endpoint = "/rest/getDepositStatementForPeriod_V2"
            let method: ServerCommandMethod = .post
            let payload: BasePayload?
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: [ProductStatementData]?
            }
            
            internal init(token: String, payload: BasePayload) {
                
                self.token = token
                self.payload = payload
            }
            
            init(token: String, productId: ProductData.ID, period: Period) {
                
                self.init(token: token, payload: .init(id: productId, startDate: period.start, endDate: period.end))
            }
        }
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/DepositController/openDepositUsingPOST
         */
        struct OpenDeposit: ServerCommand {
            
            let token: String
            let endpoint = "/rest/openDeposit"
            let method: ServerCommandMethod = .post
            
            struct Payload: Encodable { }
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: EmptyData?
            }
            
            internal init(token: String) {
                
                self.token = token
            }
        }
        
        /*
         http://192.168.50.113:8080/swagger-ui/index.html#/DepositController/saveDepositCustomName
         */
        struct SaveDepositName: ServerCommand {
            
            let token: String
            let endpoint = "/rest/saveDepositName"
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
            
            init(token: String, productId: ProductData.ID, name: String) {
                
                self.init(token: token, payload: .init(id: productId, name: name))
            }
        }
        
        /*
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/DictionaryController//dict//rest/getDepositProductListUsingGet
         */
        struct GetDepositProductList: ServerCommand {
            
            let token: String
            let endpoint = "/rest/getDepositProductList"
            let method: ServerCommandMethod = .get
            
            struct Payload: Encodable {}
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let data: [DepositProductData]?
                let errorMessage: String?
            }
            
            internal init(token: String) {
                
                self.token = token
            }
        }
        
        /*
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/DictionaryController/dict//rest/closeDeposit
         */
        struct CloseDeposit: ServerCommand {
            
            let token: String
            let endpoint = "/rest/closeDeposit"
            let method: ServerCommandMethod = .post
            let payload: Payload?
            
            struct Payload: Encodable {
                
                let id: Int
                let name: String?
                let startDate: String?
                let endDate: String?
                let statementFormat: StatementFormat?
                let accountId: Int?
                let cardId: Int?
            }
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let data: TransferData?
                let errorMessage: String?
                
                struct TransferData: Codable, Equatable {
                    
                    let paymentOperationDetailId: Int?
                    let documentStatus: String
                    let accountNumber: String?
                    let closeDate: Int?
                    let comment: String?
                    let category: String?
                }
            }
            
            internal init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
        }
        
        /*
         http://10.1.206.21:8080/swagger-ui/index.html#/DepositController/getPrintFormForDepositConditions
         */
        struct GetPrintFormForDepositConditions: ServerDownloadCommand {
            
            let token: String
            let endpoint = "/rest/getPrintFormForDepositConditions"
            let method: ServerCommandMethod = .post
            let payload: BasePayload?
            let cachePolicy: URLRequest.CachePolicy = .returnCacheDataElseLoad
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: Data?
            }
            
            init(token: String, payload: BasePayload) {
                
                self.token = token
                self.payload = payload
            }
            
            init(token: String, depositId: ProductData.ID) {
                
                self.init(token: token, payload: .init(id: depositId))
            }
        }
        
        struct BasePayload: Encodable {
            
            let id: Int
            var name: String? = nil
            var startDate: Date? = nil
            var endDate: Date? = nil
            var statementFormat: StatementFormat? = nil
        }
    }
}
