//
//  ItemAction.swift
//  
//
//  Created by Andryusina Nataly on 09.10.2024.
//

import Foundation

public struct ItemAction: Equatable {
    
    let type: String
    let target: String?
    
    public init(type: String, target: String?) {
        self.type = type
        self.target = target
    }
}
