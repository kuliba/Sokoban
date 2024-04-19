//
//  ArrayOfProductData+Extensions.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 19.04.2024.
//

import Foundation

extension Array where Element == ProductData {
    
    func groupingByParentID() -> [ProductData.ID: [ProductData]] {
                
        return self.reduce(into: [ProductData.ID: [ProductData]](), { currentResult, productData in
            if let parentID = productData.asCard?.idParent {
                currentResult[parentID, default: []].append(productData)
            }
        }).mapValues { $0.sorted(by: \.order) }
    }
    
    func productsWithoutAdditional() -> [ProductData] {
        
        return self.filter {
            $0.asCard?.idParent == nil
        }
    }
    
    func cardsWithoutAdditional() -> [ProductData] {
        
        return self.filter {
            $0.productType == .card && $0.asCard?.idParent == nil
        }
    }
    
    func productsWithoutCards() -> [ProductData] {
        
        return self.filter { $0.productType != .card }
    }
    
    func cardsWithAdditional() -> [ProductData] {
        
        let groupingByParentID = self.groupingByParentID()
        
        let cardsWithoutAdditional = self.cardsWithoutAdditional()
        
        var cardsWithAdditional: [ProductData] = []
        
        cardsWithoutAdditional.forEach {
            
            cardsWithAdditional.append($0)

            if let additional = groupingByParentID[$0.id] {
                cardsWithAdditional.append(contentsOf: additional)
            }
        }
        
        let cardsWithAdditionalIDs = cardsWithAdditional.map(\.id)
        
        groupingByParentID.forEach { key, value in
            
            if !cardsWithAdditionalIDs.contains(key) {
                cardsWithAdditional.append(contentsOf: value)
            }
        }
        return cardsWithAdditional
    }
    
    func groupingAndSortedProducts() -> [ProductData] {
                        
        let allProducts = self.productsWithoutCards() + self.cardsWithAdditional()
        
        return allProducts.sorted(by: \.productType.order)
    }
}
