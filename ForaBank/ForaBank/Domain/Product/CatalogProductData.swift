//
//  CatalogProductData.swift
//  ForaBank
//
//  Created by Max Gribov on 25.02.2022.
//

import Foundation

struct CatalogProductData: Decodable, Equatable {

    let name: String
    let deescription: [String]
    let imageEndpoint: String
    let infoURL: URL
    let orderURL: URL
    
    enum CodingKeys : String, CodingKey {
        
        case name = "productName"
        case deescription = "txtСondition"
        case imageEndpoint = "imageLink"
        case infoURL = "conditionLink"
        case orderURL = "orderLink"
    }
}
