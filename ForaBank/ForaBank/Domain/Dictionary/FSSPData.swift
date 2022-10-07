//
//  FSSPData.swift
//  ForaBank
//
//  Created by Max Gribov on 03.02.2022.
//

import Foundation

struct FSSPDebtData: Codable, Equatable {
    
    let text: String
    let value: String
}

struct FSSPDocumentData: Codable, Equatable {
    
    let text: String
    let value: String
    let svgImage: SVGImageData
}
