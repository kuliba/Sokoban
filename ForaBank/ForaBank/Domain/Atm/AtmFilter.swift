//
//  AtmFilter.swift
//  ForaBank
//
//  Created by Max Gribov on 07.04.2022.
//

import Foundation

struct AtmFilter {
    
    let categories: Set<AtmData.Category>
    let services: Set<AtmServiceData.ID>
    
    var types: Set<AtmTypeData.ID> { Set(categories.flatMap({ $0.types })) }
}

extension AtmFilter {
    
    static let emptyMock = AtmFilter(categories: [], services: [])
}
