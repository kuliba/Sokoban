//
//  PromoItem.swift
//  Vortex
//
//  Created by Andryusina Nataly on 23.01.2025.
//

import Foundation
import GetBannersMyProductListService
import RemoteServices

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
    
    init(_ item: CardBannerList) {
        
        self.init(
            productName: item.productName,
            link: item.link,
            md5hash: item.md5hash,
            action: item.action.map { .init($0) },
            productType: .card,
            promoProduct: .sticker
        )
    }
    
    init(
        item: BannerList.Item,
        productType: ProductType,
        promoProduct: PromoProduct
    ) {
        
        self.init(
            productName: item.productName,
            link: item.link,
            md5hash: item.md5hash,
            action: item.action.map { .init($0) },
            productType: productType,
            promoProduct: promoProduct
        )
    }
}

extension PromoItem.PromoAction {
    
    init(_ action: CardBannerAction) {
        
        self.init(type: action.actionType, target: action.landingDate)
    }
    
    init(_ action: BannerList.Action) {
        
        self.init(type: action.actionType, target: action.target)
    }
}

extension PromoItem {
    
    typealias PromoBanner = RemoteServices.ResponseMapper.GetBannersMyProductListResponse.Banner
    
    init(
        _ item: PromoBanner,
        type: ProductType,
        promoProduct: PromoProduct
    ) {
        
        self.init(
            productName: item.productName,
            link: item.link,
            md5hash: item.md5hash,
            action: item.action.map { .init($0) },
            productType: type,
            promoProduct: promoProduct
        )
    }
}

extension PromoItem.PromoAction {
    
    typealias Action = RemoteServices.ResponseMapper.GetBannersMyProductListResponse.Banner.Action

    init(_ action: Action) {
        
        self.init(type: action.actionType, target: action.target)
    }
}

extension PromoItem {
    /*
     {
         "productName": "Накопительный счет",
         "link": "",
         "md5hash": "3e0d7b5a2a1522c9d67e048f7c807afb",
         "action": {
             "target": "DEFAULT",
             "actionType": "SAVING_LANDING"
         }
     }

     */
    static let savingsAccountPreview: Self = .init(
        productName: "Накопительный счет",
        link: "",
        md5hash: "3e0d7b5a2a1522c9d67e048f7c807afb",
        action: .init(type: "SAVING_LANDING", target: "DEFAULT"),
        productType: .account,
        promoProduct: .savingsAccount
    )
}

extension PromoItem {
    
    func mapper(
        onTap: @escaping () -> Void,
        onHide: @escaping () -> Void
    ) -> AdditionalProductViewModel {
        
        .init(
            md5Hash: md5hash,
            productType: productType,
            promoType: promoProduct,
            onTap: onTap,
            onHide: onHide
        )
    }
}
