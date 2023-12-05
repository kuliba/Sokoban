//
//  Location.swift
//  
//
//  Created by Дмитрий Савушкин on 05.12.2023.
//

import Foundation

public struct Location: Hashable, Identifiable {
    
    public let id: String
    
    public init(id: String) {
        self.id = id
    }
}
