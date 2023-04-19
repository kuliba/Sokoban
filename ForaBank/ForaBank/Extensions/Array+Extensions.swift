//
//  Array+Extensions.swift
//  RealmPlayground
//
//  Created by Max Gribov on 03.12.2021.
//

import Foundation

extension Array where Element: Equatable, Element: Identifiable {
    
    func update(with other: [Element]) -> (updates: [Element], additions: [Element], removals: [Element])? {
        
        let diff = other.difference(from: self)
        guard let result = self.applying(diff) else {
            
            return nil
        }
        
        let removals = self.missing(in: result)
        let updated = self.contained(in: result)
        let updates = result.contained(in: updated)
        let additions = result.missing(in: updates + removals)
        
        return (updates, additions, removals)
    }
}

extension Array where Element: Identifiable {
    
    func contained(in other: [Element]) -> [Element] {
        
        let otherIds = other.map{ $0.id }
        return self.filter{ otherIds.contains($0.id)}
    }
    
    func missing(in other: [Element]) -> [Element] {
        
        let otherIds = other.map{ $0.id }
        return self.filter{ otherIds.contains($0.id) == false }
    }
}

extension Array where Element: Hashable {
    
    func diff(from other: [Element]) -> [Element] {
        
        let thisSet = Set(self)
        let otherSet = Set(other)
        
        return Array(thisSet.symmetricDifference(otherSet))
    }
}

extension Array where Element == ProductDataFilterRule {
    
    var currencyRules: [ProductData.Filter.CurrencyRule] {
        
        compactMap { $0 as? ProductData.Filter.CurrencyRule }
    }
    
    var debitRules: [ProductData.Filter.DebitRule] {
        
        compactMap { $0 as? ProductData.Filter.DebitRule }
    }

    var restrictedDepositRules: [ProductData.Filter.DebitRule] {
        
        compactMap { $0 as? ProductData.Filter.DebitRule }
    }
}

