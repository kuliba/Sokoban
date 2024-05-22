//
//  Dictionary+ProductData.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 22.05.2024.
//

import Foundation

extension Dictionary where Key == ProductData.ID, Value == [ProductData] {
    
    func selectionAvailable(_ productID: ProductData.ID) -> Bool {
        
        if let products = self[productID] {
            return products.count == 1
        } else {
            
            let result = self.contains { $0.value.contains { $0.id == productID } &&  $0.value.count > 1 }
            return !result
        }
    }
}
