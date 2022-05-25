//
//  BannerCatalogListData.swift
//  ForaBank
//
//  Created by Дмитрий on 05.03.2022.
//

import Foundation

struct BannerCatalogListData: Codable, Equatable, Identifiable {
    
    var id: String { imageEndpoint }
    let productName: String
    let conditions: [String]
    let imageEndpoint: String
    let orderURL: URL
    let conditionURL: URL
    
    enum CodingKeys : String, CodingKey, Decodable {
        
        case productName
        case conditions = "txtСondition"
        case imageEndpoint = "imageLink"
        case orderURL = "orderLink"
        case conditionURL = "conditionLink"
    }
}
