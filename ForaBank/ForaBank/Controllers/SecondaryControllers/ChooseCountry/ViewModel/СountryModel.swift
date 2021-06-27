//
//  СountryModel.swift
//  ForaBank
//
//  Created by Mikhail on 06.06.2021.
//

import Foundation


public struct Country : Decodable {
    
    static var countries: [CountriesList]?
    
    public let name : String?
    public let code : String?
    public let imageSVGString : String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case code
        case imageSVGString
    }
}
