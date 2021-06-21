//
//  СountryModel.swift
//  ForaBank
//
//  Created by Mikhail on 06.06.2021.
//

import Foundation


public struct Country : Decodable {

    static var countries: [GetCountryDatum]?
    
    public let name : String?
    public let dialCode : String?
    public let code : String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case code
        case dialCode = "dial_code"
    }
}
