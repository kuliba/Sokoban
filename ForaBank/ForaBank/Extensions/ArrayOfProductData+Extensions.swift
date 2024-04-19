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
}
