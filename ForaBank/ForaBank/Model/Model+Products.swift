//
//  Model+Products.swift
//  ForaBank
//
//  Created by Max Gribov on 09.03.2022.
//

import Foundation

//MARK: - Handlers

extension Model {
    
    func handleProductsUpdateFastAll() {
        
        
    }
    
    func handleProductsUpdateFastSingleRequest(_ payload: ModelAction.Products.Update.Fast.Single.Request) {
        
        
    }
    
    func handleProductsUpdateTotalAll() {
        
        
    }
    
    func handleProductsUpdateTotalSingleRequest(_ payload: ModelAction.Products.Update.Total.Single.Request) {
        
        
    }
    
    func reduce(products: [ProductType: [ProductData]], with productsData: [ProductData]) -> [ProductType: [ProductData]] {
        
        var productsUpdated = products
        
        for productType in ProductType.allCases {
            
            let productsTypeData = productsData.filter{ $0.productType == productType }
            
            guard productsTypeData.isEmpty == false else {
                continue
            }
            
            productsUpdated[productType] = productsTypeData
        }
        
        return productsUpdated
    }
    
    func reduce(products: [ProductType: [ProductData]], with params: ProductDynamicParams) -> [ProductType: [ProductData]] {
        
        let productType = params.type
        
        guard let productsTypeData = products[productType] else {
            return products
        }
        
        var productsUpdated = products
        var productsTypeDataUpdated = [ProductData]()
        
        for product in productsTypeData {
            
            if product.id == params.id  {
                
                let productUpdated = product.updated(with: params)
                productsTypeDataUpdated.append(productUpdated)
                
            } else {
                
                productsTypeDataUpdated.append(product)
            }
        }
       
        productsUpdated[productType] = productsTypeDataUpdated
        
        return productsUpdated
    }
}

//MARK: - Actions

extension ModelAction {
    
    enum Products {
    
        enum Update {
        
            enum Fast {
                
                struct All: Action {}
                
                enum Single {
                    
                    struct Request: Action {
                        
                        let productId: ProductData.ID
                        let productType: ProductType
                    }
                    
                    struct Response: Action {
                        
                        let productId: ProductData.ID
                        let productType: ProductType
                        let result: Result<ProductDynamicParams, Error>
                    }
                }
            }
            
            enum Total {
                
                struct All: Action {}
                
                enum Single {
                
                    struct Request: Action {
                        
                        let productType: ProductType
                    }
                    
                    struct Response: Action {

                        let productType: ProductType
                        let result: Result<[ProductData], Error>
                    }
                }
            }
        }
    }
}
