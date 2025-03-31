//
//  Descriptor.swift
//  
//
//  Created by Igor Malyarov on 31.03.2025.
//

public struct Descriptor: Equatable {
    
    public let items: [Item] // TODO: improve with non-empty?
    public let title: String
    
    public init(
        items: [Item],
        title: String
    ) {
        self.items = items
        self.title = title
    }
}

extension Descriptor {
    
    public struct Item: Equatable {
        
        public let md5Hash: String
        public let title: String
        public let value: String
        
        public init(
            md5Hash: String,
            title: String,
            value: String
        ) {
            self.md5Hash = md5Hash
            self.title = title
            self.value = value
        }
    }
}
