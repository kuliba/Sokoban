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
