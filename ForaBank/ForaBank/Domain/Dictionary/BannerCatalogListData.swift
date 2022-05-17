//
//  BannerCatalogListData.swift
//  ForaBank
//
//  Created by Дмитрий on 05.03.2022.
//

import Foundation

struct BannerCatalogListData: Codable, Equatable {
    
    let conditionLink: URL
    let imageLink: String
    let orderLink: URL
    let productName: String
    let txtСondition: [String]
}
