//
//  AnywayElement.Field.swift
//
//
//  Created by Igor Malyarov on 08.06.2024.
//

extension AnywayElement {
    
    public struct Field: Identifiable, Equatable {
        
        public let id: ID
        public let title: String
        public let value: Value
        public let image: Image?
        
        public init(
            id: ID,
            title: String,
            value: Value,
            image: Image?
        ) {
            self.id = id
            self.title = title
            self.value = value
            self.image = image
        }
        
        public typealias ID = String
        public typealias Value = String
    }
}
