//
//  ServerCommands+Card.swift
//  ForaBank
//
//  Created by Дмитрий on 20.01.2022.
//

import Foundation
import ServerAgent

extension ServerCommands {
    
    enum CardController {
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/rest/blockCard
         */
        struct BlockCard: ServerCommand {
            
            let token: String
            let endpoint = "/rest/blockCard"
            let method: ServerCommandMethod = .post
            let payload: Payload?
            
            struct Payload: Encodable {
                
                let cardId: Int
                let cardNumber: String?
            }
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: BlockResponseData?
            }
            
            internal init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
        }
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/rest/getCardStatement
         */
        struct GetCardStatement: ServerCommand {
            
            let token: String
            let endpoint = "/rest/getCardStatement_V2"
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
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/rest/getOwnerPhoneNumber
         */
        struct GetOwnerPhoneNumber: ServerCommand {
            
            let token: String
            let endpoint = "/rest/getOwnerPhoneNumber"
            let method: ServerCommandMethod = .post
            let payload: Payload?
            
            struct Payload: Encodable {
                
                let phoneNumber: String
            }
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: String?
            }
            
            internal init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
        }
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/rest/saveCardName
         */
        struct SaveCardName: ServerCommand {
            
            let token: String
            let endpoint = "/rest/saveCardName"
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
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/rest/unblockCard
         */
        struct UnblockCard: ServerCommand {
            
            let token: String
            let endpoint = "/rest/unblockCard"
            let method: ServerCommandMethod = .post
            let payload: Payload?
            
            struct Payload: Encodable {
                
                let cardID: Int
                let cardNumber: String?
            }
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: BlockResponseData?
            }
            
            internal init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
        }
        
        
        /*
         http://10.1.206.21:8080/swagger-ui/index.html#/CardController/getPrintFormForCardStatement
         */
        struct GetPrintFormForCardStatement: ServerDownloadCommand {
            
            let token: String
            let endpoint = "/rest/getPrintFormForCardStatement"
            let method: ServerCommandMethod = .post
            let payload: BasePayload?
            let cachePolicy: URLRequest.CachePolicy = .returnCacheDataElseLoad
            
            init(token: String, payload: BasePayload) {
                
                self.token = token
                self.payload = payload
            }
            
            init(token: String, cardId: ProductData.ID) {
                
                self.init(token: token, payload: .init(id: cardId))
            }
        }
        
        struct BasePayload: Encodable {
            
            let id: Int
            var name: String? = nil
            var startDate: Date? = nil
            var endDate: Date? = nil
            var statementFormat: StatementFormat? = nil
            var cardNumber: String? = nil
        }
        
        struct BlockResponseData: Codable, Equatable {
            
            let statusBrief: String?
            let statusDescription: String?
        }
    }
}
