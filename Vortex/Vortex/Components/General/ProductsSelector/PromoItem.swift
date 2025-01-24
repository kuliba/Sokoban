//
//  PromoItem.swift
//  Vortex
//
//  Created by Andryusina Nataly on 23.01.2025.
//

import Foundation

struct PromoItem: Equatable {
    
    let productName: String
    let link: String
    let md5hash: String
    let action: PromoAction?
    let productType: ProductType
    let promoProduct: PromoProduct
    
    struct PromoAction: Equatable {
        
        let type: String?
        let target: String?
    }
}

extension PromoItem {
    
    init(_ item: StickerBannersMyProductList) {
        
        self.init(
            productName: item.productName,
            link: item.link,
            md5hash: item.md5hash,
            action: item.action.map { .init($0) },
            productType: .card,
            promoProduct: .sticker
        )
    }
}

extension PromoItem.PromoAction {
    
    init(_ action: CardBannerAction) {
        
        self.init(type: action.actionType, target: action.landingDate)
    }
}
