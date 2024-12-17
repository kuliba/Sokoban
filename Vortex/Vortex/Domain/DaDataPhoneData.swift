//
//  DaDataPhoneData.swift
//  ForaBank
//
//  Created by Дмитрий on 03.02.2022.
//

import Foundation

struct DaDataPhoneData: Codable, Equatable {
    
    let city: String?
    let cityCode: String
    let country: String
    let countryCode: String
    let `extension`: String?
    let md5hash: String
    let number: String
    let phone: String
    let provider: String
    let puref: String
    let qc: Int
    let qcConflict: Int
    let region: String
    let source: String
    let svgImage: String
    let timezone: String
    let type: String
}
