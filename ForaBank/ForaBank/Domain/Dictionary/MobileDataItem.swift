//
//  MobileDataItem.swift
//  ForaBank
//
//  Created by Дмитрий on 02.02.2022.
//

import Foundation

struct MobileDataItem: Codable, Equatable {
    
    let code: String
    let md5hash: String
    let providerName: String
    let puref: String
    let shortName: String
    let svgImage: SVGImageData
}
