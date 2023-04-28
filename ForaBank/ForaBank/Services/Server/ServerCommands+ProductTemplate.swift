//
//  ServerCommands+ProductTemplate.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 14.02.2023.
//

import Foundation

extension ServerCommands {
    
    enum ProductTemplateController {
        
        /*
         https://pl.forabank.ru/dbo/api/v3/swagger-ui/index.html#/ProductTemplateController/deleteProductTemplate
         */
        struct DeleteProductTemplate: ServerCommand {
            
            let token: String
            let endpoint = "/rest/deleteProductTemplate"
            let method: ServerCommandMethod = .delete
            let parameters: [ServerCommandParameter]?
            
            struct Payload: Encodable {}
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: EmptyData?
            }
            
            internal init(token: String, productId: Int) {
                
                self.token = token
                
                var parameters = [ServerCommandParameter]()
                parameters.append(.init(name: "productId", value: "\(productId)"))
                
                self.parameters = parameters
            }
        }
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/ProductTemplateController/getProductTemplateList
         */
        struct GetProductTemplateList: ServerCommand {
            
            let token: String
            let endpoint = "/rest/getProductTemplateList"
            let method: ServerCommandMethod = .get
            
            struct Payload: Encodable {}
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: [ProductTemplateData]?
            }
            
            internal init(token: String) {
                
                self.token = token
            }
        }
    }
}
