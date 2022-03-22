//
//  BankData.swift
//  ForaBank
//
//  Created by Дмитрий on 02.02.2022.
//

import Foundation

struct BankData: Codable, Equatable, Cachable {
    
    let md5hash: String
    let memberId: String?
    let memberName: String?
    let memberNameRus: String
    let paymentSystemCodeList: [String]
    let svgImage: SVGImageData
}
