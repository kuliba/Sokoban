//
//  AtmRegionData.swift
//  ForaBank
//
//  Created by Max Gribov on 12.04.2022.
//

import Foundation

struct AtmRegionData: Identifiable, Codable, Equatable, Cachable  {
    
    let id: Int
    let name: String
}
