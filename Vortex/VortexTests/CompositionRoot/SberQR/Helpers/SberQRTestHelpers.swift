//
//  SberQRTestHelpers.swift
//  VortexTests
//
//  Created by Igor Malyarov on 09.12.2023.
//

@testable import Vortex
import SberQR

extension Model {
    
    func changeProducts(to products: ProductsData) {
        
        self.products.send(products)
    }
    
    var cards: [ProductCardData] {
        
        allProducts
            .filter { $0.productType == .card }
            .compactMap { $0 as? ProductCardData }
    }
    
    var accounts: [ProductAccountData] {
        
        allProducts
            .filter { $0.productType == .account }
            .compactMap { $0 as? ProductAccountData }
    }
}

extension Array where Element == GetSberQRDataResponse.Parameter {
    
    var hasProductSelect: Bool {
        
        !allSatisfy {
            
            switch $0 {
            case .productSelect:
                return false
                
            default:
                return true
            }
        }
    }
}
