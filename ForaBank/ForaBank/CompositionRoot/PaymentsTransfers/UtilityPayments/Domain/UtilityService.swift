//
//  UtilityService.swift
//  ForaBank
//
//  Created by Igor Malyarov on 27.02.2024.
//

import Foundation

struct UtilityService: Equatable {
    
    let name: String
    let puref: String
}

extension UtilityService: Identifiable {
    
    var id: String { puref }
}

