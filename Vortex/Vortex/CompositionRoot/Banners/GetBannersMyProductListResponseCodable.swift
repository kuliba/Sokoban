//
//  GetBannersMyProductListResponseCodable.swift
//  Vortex
//
//  Created by Andryusina Nataly on 17.02.2025.
//

import Foundation

struct GetBannersMyProductListResponseCodable: Codable {
    
    let accountBannerList: [Item]?
    let cardBannerList: [Item]?
    let loanBannerList: [Item]?
    
    struct Item: Codable {
        
        let action: Action?
        let link: String
        let md5hash: String
        let productName: String
    }
    
    struct Action: Codable {
        
        let actionType: String
        let target: String?
    }
}
