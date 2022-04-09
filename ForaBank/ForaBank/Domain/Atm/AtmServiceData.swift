//
//  AtmServiceData.swift
//  ForaBank
//
//  Created by Max Gribov on 04.04.2022.
//

import Foundation

struct AtmServiceData: Identifiable, Codable, Equatable, Cachable {
    
    let id: Int
    let name: String
}
