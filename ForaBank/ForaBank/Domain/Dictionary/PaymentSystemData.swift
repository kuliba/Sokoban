//
//  PaymentSystemData.swift
//  ForaBank
//
//  Created by Дмитрий on 02.02.2022.
//

import Foundation

struct PaymentSystemData: Codable, Equatable {
    
    let code: String
    let md5hash: String
    let name: String
    var purefList: [[String: [PurefData]]]?
    let svgImage: SVGImageData
}

extension PaymentSystemData {
    
    struct PurefData: Codable, Equatable {
        
        let puref: String
        let type: String
    }
}


