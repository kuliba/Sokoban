//
//  Product.swift
//  
//
//  Created by Igor Malyarov on 09.02.2025.
//

public struct Product: Equatable, Identifiable {
    
    public var id: String { typeText }
    public let image: String
    public let typeText: String
    public let header: String
    public let subtitle: String
    public let orderTitle: String
    public let serviceTitle: String
    
    public init(
        image: String,
        typeText: String,
        header: String,
        subtitle: String,
        orderTitle: String,
        serviceTitle: String
    ) {
        self.image = image
        self.typeText = typeText
        self.header = header
        self.subtitle = subtitle
        self.orderTitle = orderTitle
        self.serviceTitle = serviceTitle
    }
}
