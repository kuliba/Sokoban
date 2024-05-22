//
//  Info.swift
//  
//
//  Created by Igor Malyarov on 22.05.2024.
//

public struct Info: Equatable {
    
    public let id: ID
    public let title: String
    public let value: String
    let style: Style
    
    public init(
        id: ID,
        title: String,
        value: String,
        style: Style
    ) {
        self.id = id
        self.title = title
        self.value = value
        self.style = style
    }
}

public extension Info {
    
    enum ID: Equatable {
        
        case amount, brandName, recipientBank
    }

    enum Style {
        
        case expanded
        case compressed
    }
}
