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
                let data: List?
                
                struct List: Codable, Equatable {
                    
                    let serial: String
                    let productList: [ProductData]
                }

                private enum CodingKeys : String, CodingKey {

                    case statusCode
                    case errorMessage
                    case data
                }

                private enum ListCodingKeys : String, CodingKey {

                    case serial
                    case productList
                }

                init(statusCode: ServerStatusCode, errorMessage: String?, data: List?) {

                    self.statusCode = statusCode
                    self.errorMessage = errorMessage
                    self.data = data
                }

                init(from decoder: Decoder) throws {

                    let container = try decoder.container(keyedBy: CodingKeys.self)
                    statusCode = try container.decode(ServerStatusCode.self, forKey: .statusCode)
                    errorMessage = try container.decodeIfPresent(String.self, forKey: .errorMessage)

                    let nestedContainer = try container.nestedContainer(keyedBy: ListCodingKeys.self, forKey: .data)
                    let serial = try nestedContainer.decode(String.self, forKey: .serial)
                    var listContainer = try nestedContainer.nestedUnkeyedContainer(forKey: .productList)

                    var data: [ProductData] = []
                    var items = listContainer

                    while listContainer.isAtEnd == false {

                        let productData = try listContainer.decode(ProductData.self)

                        switch productData.productType {
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

                    self.data = .init(serial: serial, productList: data)
                }
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
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/ProductController//rest/getProductDynamicParams
         */
        struct GetProductDynamicParams: ServerCommand {
            
            let token: String?
            let endpoint = "/rest/getProductDynamicParams"
            let method: ServerCommandMethod = .post
            let parameters: [ServerCommandParameter]? = nil
            let payload: Payload?
            let timeout: TimeInterval? = nil
            
            struct Payload: Encodable {
                
                let accountId: String?
                let cardId: String?
                let depositId: String?
            }
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: ProductDynamicParamsData?
            }
            
            internal init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
        }
        
        /*
         https://test.inn4b.ru/dbo/api/v3/swagger-ui/index.html#/ProductController/rest/getProductDynamicParamsList
         */
        struct GetProductDynamicParamsList: ServerCommand {
            
            let token: String?
            let endpoint = "/rest/getProductDynamicParamsList"
            let method: ServerCommandMethod = .post
            let parameters: [ServerCommandParameter]? = nil
            let payload: Payload?
            let timeout: TimeInterval? = nil
            
            struct Payload: Encodable {
                
                var productList: [ProductListData]
                
                struct ProductListData: Encodable {
                    
                    let id: Int
                    let type: ProductType
                }
            }
            
            struct Response: ServerResponse {
                
                let statusCode: ServerStatusCode
                let errorMessage: String?
                let data: List?

                struct List: Codable, Equatable {
                    
                    let dynamicProductParamsList: [DynamicListParams]
                    
                    static func == (lhs: ServerCommands.ProductController.GetProductDynamicParamsList.Response.List, rhs: ServerCommands.ProductController.GetProductDynamicParamsList.Response.List) -> Bool {
                        return lhs.dynamicProductParamsList == rhs.dynamicProductParamsList
                    }
                    
                    struct DynamicListParams: Codable, Equatable {
                        
                        let id: Int
                        let type: ProductType
                        let dynamicParams: ProductDynamicParamsData
                    }
                }
            }

            
            internal init(token: String, payload: Payload) {
                
                self.token = token
                self.payload = payload
            }
            
            init(token: String, products: [ProductData]) {
                
                self.token = token
                
                var productListData = [Payload.ProductListData]()
                
                for product in products {
                    
                    productListData.append(.init(id: product.id, type: product.productType))
                }
                
                self.payload = .init(productList: productListData)
            }
        }
    }
}
