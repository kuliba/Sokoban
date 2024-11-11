//
//  ServerCommands+DepositController.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 1/31/22.
//

import Foundation
import ServerAgent

extension ServerCommands {
    
    enum DepositController {
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/DepositController/getDepositInfoUsingPOST
         */
        struct GetDepositInfo: ServerCommand {
            
            let token: String
            let endpoint = "/rest/getDepositInfo_V2"
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
            let endpoint = "/rest/v4/getDepositStatementForPeriod"
            let method: ServerCommandMethod = .post
            let payload: BasePayload?
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: ProductStatementWithExtendedInfo?
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
            let serial: String?
            let endpoint = "/rest/v2/getDepositProductList"
            let method: ServerCommandMethod = .get
            
            struct Payload: Encodable {}
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let data: DepositProductList?
                let errorMessage: String?
                
                struct DepositProductList: Decodable, Equatable {
                    
                    let list: [DepositProductData]?
                    let serial: String
                }
            }
            
            internal init(token: String, serial: String?) {
                
                self.token = token
                self.serial = serial
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
                let data: CloseProductTransferData?
                let errorMessage: String?
            }
            
            internal init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
        }
        
        /*
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/DictionaryController/dict//rest/getDepositRestBeforeClosing
         */
        
        struct GetDepositRestBeforeClosing: ServerCommand {
            
            let token: String
            let endpoint = "/rest/getDepositRestBeforeClosing"
            let method: ServerCommandMethod = .post
            let payload: Payload?
            
            struct Payload: Encodable {
                
                let depositId: Int
                let operDate: String
            }
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: Double?
            }
            
            internal init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
            
            init(token: String, dateFormatter: DateFormatter, depositId: Int, operDate: Date) {
                
                self.token = token
                self.payload = .init(depositId: depositId, operDate: dateFormatter.string(from: operDate))
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
        
        /*
         http://10.1.206.21:8080/swagger-ui/index.html#/DepositController/getPrintFormForDepositAgreement
        */
        struct GetPrintFormForDepositAgreement: ServerDownloadCommand {
            
            let token: String
            let endpoint = "/rest/getPrintFormForDepositAgreement"
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
