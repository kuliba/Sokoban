//
//  AtmTypeData.swift
//  ForaBank
//
//  Created by Max Gribov on 04.04.2022.
//

import Foundation

struct AtmTypeData: Codable, Equatable, Cachable, Identifiable {
    
    let id: Int
    let name: String
}
