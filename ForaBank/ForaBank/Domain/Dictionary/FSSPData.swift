//
//  FSSPData.swift
//  ForaBank
//
//  Created by Max Gribov on 03.02.2022.
//

import Foundation

struct FSSPData: Codable, Equatable, Cachable {
    
    let md5hash: String
    let svgImage: SVGImageData
    let text: String
    let value: String
}
