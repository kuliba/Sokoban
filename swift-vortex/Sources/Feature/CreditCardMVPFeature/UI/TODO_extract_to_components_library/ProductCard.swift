//
//  ProductCard.swift
//
//
//  Created by Igor Malyarov on 25.03.2025.
//

public struct ProductCard: Equatable {
    
    public let md5Hash: String
    public let options: [Option]
    public let title: String
    public let subtitle: String
    
    public init(
        md5Hash: String,
        options: [Option],
        title: String,
        subtitle: String
    ) {
        self.md5Hash = md5Hash
        self.options = options
        self.title = title
        self.subtitle = subtitle
    }
}

extension ProductCard {
    
    public struct Option: Equatable {
        
        public let title: String
        public let value: String
        
        public init(
            title: String,
            value: String
        ) {
            self.title = title
            self.value = value
        }
    }
}
