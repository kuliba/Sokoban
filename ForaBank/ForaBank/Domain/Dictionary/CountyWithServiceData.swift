//
//  CountyWithServiceData.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 31.01.2023.
//

import Foundation

struct CountryWithServiceData: Codable, Equatable, Identifiable {
    
    var id: String { code }
    let code: String
    let contactCode: String?
    let name: String
    let sendCurr: String
    let md5hash: String?
    let servicesList: [Service]
    
    struct Service: Codable, Equatable {
        
        let code: Code
        let isDefault: Bool
        
        enum Code: String, Codable, Unknownable {
            
            case direct = "iFora||MIG"
            case directCard = "iFora||MIG||card"
            case contact = "iFora||Addressless"
            case contactCash = "iFora||Addressing||cash"
            case contactAccount = "iFora||Addressing||account"
            case unknown
        }
    }
}
