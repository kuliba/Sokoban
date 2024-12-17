//
//  Option.swift
//  ForaBank
//
//  Created by Max Gribov on 20.01.2022.
//

import Foundation

struct Option: Identifiable {
    
    let id: String
    let name: String
    let subtitle: String?
    
    init(id: String, name: String, subtitle: String? = nil) {
        
        self.id = id
        self.name = name
        self.subtitle = subtitle
    }
}
