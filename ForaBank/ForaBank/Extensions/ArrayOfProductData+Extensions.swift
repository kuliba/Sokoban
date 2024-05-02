//
//  ArrayOfProductData+Extensions.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 19.04.2024.
//

import Foundation

extension ProductData {

    var parentID: ProductData.ID? { self.asCard?.idParent }
}

extension Array where Element == ProductData {
    
    typealias Products = [ProductData.ID: [ProductData]]
    
    func groupingCards() -> Products {
        
        return self.reduce(into: Products()) { result, productData in
            
            if (productData.asCard != nil) {
                
                let productID: Int = {
                    if let parentID = productData.parentID {
                        return parentID
                    } else { return productData.id }
                }()
                return result[productID, default: []].append(productData)
            }
        }
        .mapValues { $0.sorted(by: \.order) }
    }

    func groupingByParentID() -> Products {
                
        return self.reduce(into: Products()) { result, productData in

            productData.parentID.map {

                result[$0, default: []].append(productData)
            }
        }
        .mapValues { $0.sorted(by: \.order) }
    }
        
    func groupingByParentIDOnlySelf() -> Products {
            
        groupingByParentID().mapValues {
          
            $0.compactMap {

                let onlySelf = $0.asCard?.cardType == .additionalSelfAccOwn || $0.asCard?.cardType == .additionalSelf

                return onlySelf ? $0: nil
            }
        }
    }
    
    func productsWithoutAdditional() -> [ProductData] {
        
        return filter { $0.parentID == nil }
    }
    
    func cardsWithoutAdditional() -> [ProductData] {
        
        return filter { $0.productType == .card && $0.parentID == nil }
    }
    
    func productsWithoutCards() -> [ProductData] {
        
        return filter { $0.productType != .card }
    }
    
    func cardsWithAdditional() -> [ProductData] {
        
        let groupingByParentID = groupingByParentID()
        
        let cardsWithoutAdditional = cardsWithoutAdditional()
        
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
                        
        let allProducts = productsWithoutCards() + cardsWithAdditional()
        
        return allProducts.sorted(by: \.productType.order)
    }
    
    func balanceRub() -> Double {
        
        let accountsAndDeposits = filter { $0.productType == .account || $0.productType == .deposit }
        
        let cardsWithoutAdditional = cardsWithoutAdditional()
        let cardsWithoutAdditionalIDs = cardsWithoutAdditional.map(\.id)

        var productsForBalance: [ProductData] = accountsAndDeposits + cardsWithoutAdditional
        
        groupingByParentIDOnlySelf().forEach { key, value in
            
            if !cardsWithoutAdditionalIDs.contains(key), let first = value.first {
                productsForBalance.append(first)
            }
        }
        
        return productsForBalance.compactMap(\.balanceRub).reduce(0, +)
    }
}
