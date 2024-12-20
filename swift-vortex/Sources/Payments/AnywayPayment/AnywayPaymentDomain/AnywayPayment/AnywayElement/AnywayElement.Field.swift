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
        public let icon: Icon?
        
        public init(
            id: ID,
            title: String,
            value: Value,
            icon: Icon?
        ) {
            self.id = id
            self.title = title
            self.value = value
            self.icon = icon
        }
        
        public typealias ID = String
        public typealias Value = String
    }
}
