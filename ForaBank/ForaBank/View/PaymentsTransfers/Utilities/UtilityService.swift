//
//  UtilityService.swift
//  ForaBank
//
//  Created by Igor Malyarov on 27.02.2024.
//

import Foundation

struct UtilityService: Equatable, Identifiable {
    
    let id: String
    
    init(id: String = UUID().uuidString) {
     
        self.id = id
    }
}
