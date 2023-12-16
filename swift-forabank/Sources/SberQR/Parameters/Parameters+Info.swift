//
//  Parameters+Info.swift
//
//
//  Created by Igor Malyarov on 16.12.2023.
//

public extension Parameters {
    
    struct Info<ID> {
        
        public let id: ID
        public let value: String
        public let title: String
        public let icon: Icon
        
        public init(
            id: ID,
            value: String,
            title: String,
            icon: Icon
        ) {
            self.id = id
            self.value = value
            self.title = title
            self.icon = icon
        }
    }
}

extension Parameters.Info: Equatable where ID: Equatable {}

public extension Parameters.Info {
    
    struct Icon: Equatable {
        
        public let type: IconType
        public let value: String
        
        public init(
            type: IconType,
            value: String
        ) {
            self.type = type
            self.value = value
        }
        
        public enum IconType: Equatable {
            
            case local
            case remote
        }
    }
}
