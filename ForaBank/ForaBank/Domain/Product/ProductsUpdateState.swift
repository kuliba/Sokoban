//
//  ProductsUpdateState.swift
//  ForaBank
//
//  Created by Max Gribov on 09.03.2022.
//

import Foundation

enum ProductsUpdateState {
    
    case idle
    case fast(Set<ProductType>)
    case total(Set<ProductType>)
}
