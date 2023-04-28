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
    let paymentSystemIdList: [PaymentSystem]
    let sendCurr: String
    let svgImage: SVGImageData?
    
    enum PaymentSystem: String, Codable, Unknownable {
    
        case direct = "DIRECT"
        case contact = "CONTACT"
        case unknown
    }
}
