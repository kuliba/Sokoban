//
//  Product.swift
//
//
//  Created by Igor Malyarov on 16.01.2024.
//

import Tagged

public struct Product: Identifiable {
    
    public let id: ProductID
    
    public typealias ProductID = Tagged<_ProductID, String>
    public enum _ProductID {}
    
    public init(id: ProductID) {
        
        self.id = id
    }
}
