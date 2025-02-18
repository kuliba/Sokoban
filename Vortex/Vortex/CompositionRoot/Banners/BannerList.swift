//
//  BannerList.swift
//  Vortex
//
//  Created by Andryusina Nataly on 17.02.2025.
//

import Foundation

struct BannerList {
    
    let cardBannerList: [Item]?
    let accountBannerList: [Item]?
    let loanBannerList: [Item]?
    
    struct Item {
        
        let action: Action?
        let link: String
        let md5hash: String
        let productName: String
    }
    
    struct Action {
        
        let actionType: String
        let target: String?
    }
}
