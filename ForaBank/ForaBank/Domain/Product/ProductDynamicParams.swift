//
//  ProductDynamicParams.swift
//  ForaBank
//
//  Created by Max Gribov on 09.03.2022.
//

import Foundation

struct ProductDynamicParams: Codable, Hashable {
    
    let id: Int
    let type: ProductType
    let dynamicParams: Params
    
    struct Params: Codable, Hashable {
        
        let balance: Double
        let balanceRUB: Double?
        let customName: String?
    }
}
