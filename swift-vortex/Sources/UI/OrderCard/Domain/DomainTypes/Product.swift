//
//  Product.swift
//  
//
//  Created by Igor Malyarov on 09.02.2025.
//

public struct Product {
    
    public let image: String
    public let header: (String, String)
    public let orderOption: (open: String, service: String)
    
    public init(
        image: String,
        header: (String, String),
        orderOption: (open: String, service: String)
    ) {
        self.image = image
        self.header = header
        self.orderOption = orderOption
    }
}
