//
//  MosParkingDataItem.swift
//  ForaBank
//
//  Created by Дмитрий on 02.02.2022.
//

import Foundation

struct MosParkingDataItem: Codable, Equatable {
    
    let `default`: Bool?
    let groupName: String
    let md5hash: String?
    let svgImage: SVGImageData?
    let text: String?
    let value: String
}
