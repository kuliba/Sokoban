//
//  GetBannerCatalogListResponse.swift
//  
//
//  Created by Andryusina Nataly on 29.08.2024.
//

import Foundation

public struct GetBannerCatalogListResponse: Equatable {
    
    public let serial: String?
    public let bannerCatalogList: [Item]
    
    public init(
        serial: String?,
        bannerCatalogList: [Item]
    ) {
        self.serial = serial
        self.bannerCatalogList = bannerCatalogList
    }
    
    public struct Item: Equatable {
        
        let productName: String
        let conditions: [String]
        let links: Links
        let action: BannerAction?

        public init(
            productName: String,
            conditions: [String],
            links: Links,
            action: BannerAction?
        ) {
            self.productName = productName
            self.conditions = conditions
            self.links = links
            self.action = action
        }
    }
    
    public struct Links: Equatable {
        
        let image: String
        let order: String
        let condition: String
        
        public init(image: String, order: String, condition: String) {
            self.image = image
            self.order = order
            self.condition = condition
        }

    }
    
    public struct BannerAction: Equatable {
        
        let type: BannerActionType
        
        public init(
            type: BannerActionType
        ) {
            self.type = type
        }
    }
    
    public enum BannerActionType: Equatable {
        
        case openDeposit(Int)
        case depositsList
        case migTransfer(String)
        case migAuthTransfer(String)
        case contact(String)
        case depositTransfer(String)
        case landing(String)
    }
}
