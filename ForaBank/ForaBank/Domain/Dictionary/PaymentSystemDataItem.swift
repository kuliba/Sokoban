//
//  PaymentSystemDataItem.swift
//  ForaBank
//
//  Created by Дмитрий on 02.02.2022.
//

import Foundation

struct PaymentSystemDataItem: Codable, Equatable {
    
    let code: String
    let md5hash: String
    let name: String
    var purefList: [[String: [PurefData]]]?
    let svgImage: SVGImageData

    struct PurefData: Codable, Equatable {
        let puref: String
        let type: String
    }
}
