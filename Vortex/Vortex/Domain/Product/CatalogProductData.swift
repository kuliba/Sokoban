//
//  CatalogProductData.swift
//  ForaBank
//
//  Created by Max Gribov on 25.02.2022.
//

import Foundation

struct CatalogProductData: Codable, Equatable, Hashable, Identifiable {
    
    var id: Int { hashValue }
    let name: String
    let description: [String]
    let imageEndpoint: String
    let infoURL: URL
    let orderURL: URL
    let tariff: Int
    let productType: Int
    
    enum CodingKeys : String, CodingKey {
        
        case name = "productName"
        case description = "txtСondition"
        case imageEndpoint = "imageLink"
        case infoURL = "conditionLink"
        case orderURL = "orderLink"
        case tariff = "cardTarif"
        case productType = "cardType"
    }
}
