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
    
    func removeDuplicateByAccountNumber() -> [ProductData] {
        
        var uniqueProductsByAccountNumber = [ProductData]()
        
        for product in self {
            
            if !uniqueProductsByAccountNumber.contains(where: { !$0.accountNumber.isNilOrEmpty && $0.accountNumber == product.accountNumber}) {
                
                if let accountNumber = product.accountNumber, let activeProduct = cardBy(accountNumber: accountNumber, status: .active) {
                    uniqueProductsByAccountNumber.append(activeProduct)
                } else {
                    uniqueProductsByAccountNumber.append(product)
                }
            }
        }
        return uniqueProductsByAccountNumber
    }

    func cardBy(accountNumber: String, status: ProductCardData.StatusCard) -> ProductData? {
        
        first(where: {
            if let card = $0.asCard, let statusCard = card.statusCard { return card.accountNumber == accountNumber && statusCard == status }
            else { return false }
        })
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
    
    func uniqueProductIDs() -> [ProductData.ID] {
        
        return map { $0.parentID ?? $0.id }.uniqued()
    }
    
    func firstAdditionalCardByParentIDWithNoZeroBalance(_ cardID: ProductData.ID) -> ProductData? {
                
        cardsWithAdditional().first(where: { $0.parentID == cardID && ($0.balanceRub ?? 0) > 0 })
    }

    
    func balanceRub() -> Double {
        
        let accountsAndDeposits = filter { $0.productType == .account || $0.productType == .deposit }
        
        let cardsWithoutAdditional = cardsWithoutAdditional().removeDuplicateByAccountNumber()
        let cardsWithoutAdditionalIDs = cardsWithoutAdditional.map(\.id)

        var productsForBalance: [ProductData] = accountsAndDeposits + cardsWithoutAdditional
        
        groupingByParentIDOnlySelf().forEach { key, value in
            
            if cardsWithoutAdditionalIDs.contains(key) {
                if let product = cardsWithoutAdditional.first(where: { $0.id == key }), (product.balanceRub == 0 || product.balanceRub == nil),
                   let firstAdditionalCard = firstAdditionalCardByParentIDWithNoZeroBalance(key) {
                    productsForBalance.append(firstAdditionalCard)
                }
            } else if let first = value.first {
                productsForBalance.append(first)
            }
        }
        
        return productsForBalance.compactMap(\.balanceRub).reduce(0, +)
    }
}
