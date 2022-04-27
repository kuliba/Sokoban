//
//  AtmMetroStationData.swift
//  ForaBank
//
//  Created by Max Gribov on 04.04.2022.
//

import Foundation

struct AtmMetroStationData: Codable, Equatable, Cachable {
    
    let id: Int
    let name: String
    let lineName: String
    let cityId: Int
    let color: ColorData
}
