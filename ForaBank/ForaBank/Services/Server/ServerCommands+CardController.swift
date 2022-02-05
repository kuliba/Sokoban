//
//  ServerCommands+CardController.swift
//  ForaBank
//
//  Created by Дмитрий on 20.01.2022.
//

import Foundation

extension ServerCommands {
    
    enum CardController {
        
        /*
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/rest/blockCard
         */
        struct BlockCard: ServerCommand {
            
            let token: String
            let endpoint = "/rest/blockCard"
            let method: ServerCommandMethod = .post
            let parameters: [ServerCommandParameter]? = nil
            let payload: Payload?

            struct Payload: Encodable {
                
                let cardId: Int
                let cardNumber: String?
            }
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: CardBlockReturnData?
            }
            
            internal init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
        }
        
        /*
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/rest/getCardStatement
         */
        struct GetCardStatement: ServerCommand {
            
            let token: String
            let endpoint = "/rest/getCardStatement"
            let method: ServerCommandMethod = .post
            let parameters: [ServerCommandParameter]? = nil
            let payload: PayloadCardData?
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: [ProductStatementData]?
            }
            
            internal init(token: String, payload: PayloadCardData) {
                
                self.token = token
                self.payload = payload
            }
        }
        
        /*
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/rest/getOwnerPhoneNumber
         */
        struct GetOwnerPhoneNumber: ServerCommand {
            
            let token: String
            let endpoint = "/rest/getOwnerPhoneNumber"
            let method: ServerCommandMethod = .post
            let parameters: [ServerCommandParameter]? = nil
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
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/rest/saveCardName
         */
        struct SaveCardName: ServerCommand {
            
            let token: String
            let endpoint = "/rest/saveCardName"
            let method: ServerCommandMethod = .post
            let parameters: [ServerCommandParameter]? = nil
            let payload: PayloadCardData?
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: EmptyData?
            }
            
            internal init(token: String, payload: PayloadCardData) {
                
                self.token = token
                self.payload = payload
            }
        }
        
        /*
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/rest/unblockCard
         */
        struct UnblockCard: ServerCommand {
            
            let token: String
            let endpoint = "/rest/unblockCard"
            let method: ServerCommandMethod = .post
            let parameters: [ServerCommandParameter]? = nil
            let payload: Payload?

            struct Payload: Encodable {
                
                let cardID: Int
                let cardNumber: String?
            }
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: CardBlockReturnData?
            }
            
            internal init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
        }
        
        struct PayloadCardData: Encodable {
            
            let cardNumber: String?
            let endDate: Date?
            let id: Int
            let name: String?
            let startDate: Date?
            let statementFormat: StatementFormat?
        }
    }
}
