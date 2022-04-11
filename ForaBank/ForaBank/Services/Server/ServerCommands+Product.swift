//
//  ServerCommands+Product.swift
//  ForaBank
//
//  Created by Max Gribov on 01.02.2022.
//

import Foundation

extension ServerCommands {
    
    enum ProductController {
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/ProductController/getProductDetailsUsingPOST
         */
        struct GetProductDetails: ServerCommand {
            
            let token: String?
            let endpoint = "/rest/getProductDetails"
            let method: ServerCommandMethod = .post
            let parameters: [ServerCommandParameter]? = nil
            let payload: Payload?
            let timeout: TimeInterval? = nil
            
            struct Payload: Encodable {
                
                let accountId: Int?
                let cardId: Int?
                let depositId: Int?
            }
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: ProductDetailsData?
            }
            
            internal init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
        }
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/ProductController/getProductListUsingPOST
         */
        struct GetProductList: ServerCommand {
            
            let token: String?
            let endpoint = "/rest/getProductList"
            let method: ServerCommandMethod = .post
            let parameters: [ServerCommandParameter]? = nil
            let payload: Payload? = nil
            let timeout: TimeInterval? = nil
            
            struct Payload: Encodable {}
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: [ProductData]?
            }
            
            internal init(token: String) {
                
                self.token = token
            }
        }
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/ProductController/getProductListByFilterUsingGET
         */
        struct GetProductListByFilter: ServerCommand {
            
            let token: String?
            let endpoint = "/rest/getProductListByFilter"
            let method: ServerCommandMethod = .get
            let parameters: [ServerCommandParameter]?
            let payload: Payload? = nil
            let timeout: TimeInterval? = nil
            
            struct Payload: Encodable {}
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: [ProductData]?
            }
            
            internal init(token: String, isCard: Bool, isAccount: Bool, isDeposit: Bool, isLoan: Bool) {
                
                self.token = token
                var parameters = [ServerCommandParameter]()
                parameters.append(.init(name: "isCard", value: isCard.description))
                parameters.append(.init(name: "isAccount", value: isAccount.description))
                parameters.append(.init(name: "isDeposit", value: isDeposit.description))
                parameters.append(.init(name: "isLoan", value: isLoan.description))
                self.parameters = parameters
            }
        }
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/ProductController//rest/getProductListByType
         */
        struct GetProductListByType: ServerCommand {
            
            let token: String?
            let endpoint = "/rest/getProductListByType"
            let method: ServerCommandMethod = .get
            let parameters: [ServerCommandParameter]?
            let payload: Payload? = nil
            let timeout: TimeInterval? = nil
            
            struct Payload: Encodable {}
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: [ProductData]?
            }
            
            internal init(token: String, serial: String?, productType: ProductType) {
                
                self.token = token

                var parameters = [ServerCommandParameter]()
                if let serial = serial {
                    
                    parameters.append(.init(name: "serial", value: serial))
                }
                parameters.append(.init(name: "productType", value: productType.rawValue))
                self.parameters = parameters
                
            }
        }
    }
}
