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
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/ProductController/getProductDetailsUsingPOST
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
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/ProductController/getProductListUsingPOST
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
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/ProductController/getProductListByFilterUsingGET
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
                
                private enum CodingKeys : String, CodingKey {
                    case statusCode, errorMessage, data
                }
                
                internal init(statusCode: ServerStatusCode, errorMessage: String?, data: [ProductData]) {
                    self.statusCode = statusCode
                    self.errorMessage = errorMessage
                    self.data = data
                }
                
                init(from decoder: Decoder) throws {
                    
                    let container = try decoder.container(keyedBy: CodingKeys.self)
                    self.statusCode = try container.decode(ServerStatusCode.self, forKey: .statusCode)
                    self.errorMessage = try container.decodeIfPresent(String.self, forKey: .errorMessage)
                    
                    var containerItem = try container.nestedUnkeyedContainer(forKey: .data)
                    
                    var data = [ProductData]()
                    var items = containerItem
                    
                    while containerItem.isAtEnd == false {
                        
                        let productData = try containerItem.decode(ProductData.self)
                        let productType = productData.productType
                        
                        switch productType {
                        case .card:
                            
                            let productData = try items.decode(ProductCardData.self)
                            data.append(productData)
                            
                        case .account:
                            
                            let productData = try items.decode(ProductAccountData.self)
                            data.append(productData)
                            
                        case .deposit:
                            
                            let productData = try items.decode(ProductDepositData.self)
                            data.append(productData)
                            
                        case .loan:
                            
                            let productData = try items.decode(ProductLoanData.self)
                            data.append(productData)
                            
                        }
                    }
                    self.data = data
                }
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
         https://git.briginvest.ru/dbo/api/v3/swagger-ui/index.html#/ProductController//rest/getProductListByType
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
