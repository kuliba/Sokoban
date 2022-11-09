//
//  CountryData.swift
//  ForaBank
//
//  Created by Дмитрий on 02.02.2022.
//

import Foundation

struct CountryData: Codable, Equatable, Hashable, Identifiable {
    
    var id: String { code }
    let code: String
    let contactCode: String?
    let md5hash: String?
    let name: String
    let paymentSystemIdList: [String]
    let sendCurr: String
    let svgImage: SVGImageData?
}
