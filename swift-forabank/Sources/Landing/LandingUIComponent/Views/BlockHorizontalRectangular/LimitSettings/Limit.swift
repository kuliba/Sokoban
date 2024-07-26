//
//  Limit.swift
//  
//
//  Created by Andryusina Nataly on 23.07.2024.
//

import Foundation

struct Limit: Equatable {
    
    let title: String
    let value: Decimal
    let md5Hash: String
    
    init(title: String, value: Decimal, md5Hash: String) {
        self.title = title
        self.value = value
        self.md5Hash = md5Hash
    }
}
