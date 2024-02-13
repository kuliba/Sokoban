//
//  ProductProfileState.swift
//  
//
//  Created by Andryusina Nataly on 13.02.2024.
//

public struct ProductProfileState: Equatable {
    
    public var status: Status?
    
    public init(
        status: Status? = nil
    ) {
        self.status = status
    }
}

public extension ProductProfileState {

    enum Status: Equatable {
        
        case appear
        case infligth
    }
}
