//
//  AtmMetroStationData.swift
//  ForaBank
//
//  Created by Max Gribov on 04.04.2022.
//

import Foundation

struct AtmMetroStationData: Codable, Equatable {
    
    let id: Int
    let name: String
    let lineName: String
    let cityId: Int
    let color: ColorData
}
