//
//  ServerCommands+Account.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 1/18/22.
//

import Foundation
import ServerAgent

extension ServerCommands {
    
    enum AccountController {
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/AccountController/getAccountStatementUsingPOST
         */
        struct GetAccountStatement: ServerCommand {
            
            let token: String
            let endpoint = "/rest/getAccountStatement_V2"
            let method: ServerCommandMethod = .post
            var payload: BasePayload?
            
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
         http://10.1.206.21:8080/swagger-ui/index.html#/AccountController/getAccountStatementForPeriod_V2
         */
        
        //TODO: - tests
        struct GetAccountStatementForPeriod: ServerCommand {
            
            let token: String
            let endpoint = "/rest/v4/getAccountStatementForPeriod"
            let method: ServerCommandMethod = .post
            var payload: BasePayload?
            
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
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/AccountController/getPrintFormForAccountStatementUsingPOST
         */
        struct GetPrintFormForAccountStatement: ServerDownloadCommand {
            
            let token: String
            let endpoint = "/rest/getPrintFormForAccountStatement"
            let method: ServerCommandMethod = .post
            var payload: BasePayload?
            let cachePolicy: URLRequest.CachePolicy = .reloadIgnoringCacheData
            
            internal init(token: String, payload: BasePayload) {
                
                self.token = token
                self.payload = payload
            }
            
            init(token: String, accountId: ProductData.ID) {
                
                self.init(token: token, payload: .init(id: accountId))
            }
        }
        
        /*
         http://10.1.206.21:8080/swagger-ui/index.html#/AccountController/getPrintFormForCloseAccount
         */
        struct GetPrintFormForCloseAccount: ServerDownloadCommand {
            
            let token: String
            let endpoint = "/rest/getPrintFormForCloseAccount"
            let method: ServerCommandMethod = .post
            var payload: BasePayload?
            let cachePolicy: URLRequest.CachePolicy = .reloadIgnoringCacheData
            
            internal init(token: String, payload: BasePayload) {
                
                self.token = token
                self.payload = payload
            }
            
            init(token: String, accountId: ProductData.ID, paymentOperationDetailId: Int?) {
                
                self.init(token: token, payload: .init(id: paymentOperationDetailId ?? accountId, accountId: "\(accountId)"))
            }
        }
        
        /*
         http://192.168.50.113:8080/swagger-ui/index.html#/AccountController/saveAccountCustomName
         */
        struct SaveAccountName: ServerCommand {
            
            let token: String
            let endpoint = "/rest/saveAccountName"
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
        
        struct BasePayload: Encodable {
            
            let id: Int
            var name: String? = nil
            var startDate: Date? = nil
            var endDate: Date? = nil
            var statementFormat: StatementFormat? = nil
            var accountNumber: String? = nil
            var accountId: String? = nil
        }
        
        /*
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/AccountController/getAccountProductList
         */
        
        struct GetAccountProductList: ServerCommand {
            
            let token: String
            let endpoint = "/rest/getAccountProductList"
            let method: ServerCommandMethod = .get
            
            struct Payload: Encodable {}
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: [OpenAccountProductData]?
            }
            
            init(token: String) {
                
                self.token = token
            }
        }
        
        /*
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/AccountController/prepareOpenAccount
         */
        
        struct GetPrepareOpenAccount: ServerCommand {
            
            let token: String
            let endpoint = "/rest/prepareOpenAccount"
            let method: ServerCommandMethod = .post
            
            struct Payload: Encodable {}
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: OpenAccountPrepareData?
            }
            
            init(token: String) {
                
                self.token = token
            }
        }
        
        /*
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/AccountController/makeOpenAccount
         */
        
        struct GetMakeOpenAccount: ServerCommand {
            
            let token: String
            let endpoint = "/rest/makeOpenAccount"
            let method: ServerCommandMethod = .post
            let payload: Payload?
            
            struct Payload: Encodable {
                
                let cryptoVersion: String
                let verificationCode: String
                let currencyCode: Int
            }
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: OpenAccountMakeData?
            }
            
            init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
        }
        
        /*
         http://10.1.206.21:8080/swagger-ui/index.html#/DepositController/closeAccount
         */
        
        struct CloseAccount: ServerCommand {
            
            let token: String
            let endpoint = "/rest/closeAccount"
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
    }
}
