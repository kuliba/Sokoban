//
//  StickerBannerInProductListData.swift
//  Vortex
//
//  Created by Andrew Kurdin on 25.10.2023.
//

import SwiftUI

struct StickerResponseData: Codable {
    
    let serial: String
    let cardBannerList: [StickerBannersMyProductList]
    let depositBannerList: [DepositBannerList]
    let accountBannerList: [AccountBannerList]
    let loanBannerList: [LoanBannerList]
}

struct DepositBannerList: Codable {}
struct AccountBannerList: Codable {}
struct LoanBannerList: Codable {}

struct StickerBannersMyProductList: Codable, Equatable {
    
    let productName: String
    let link: String
    let md5hash: String
    let action: CardBannerAction?
}


struct CardBannerAction: Codable, Equatable {
    
    let actionType: String
    let landingDate: String
}

extension StickerBannersMyProductList {
    
    func mapper(
        md5Hash: String,
        onTap: @escaping () -> Void,
        onHide: @escaping () -> Void
    ) -> AdditionalProductViewModel {
        
        .init(
            md5Hash: md5Hash,
            productType: .card,
            promoType: .sticker,
            onTap: onTap,
            onHide: onHide
        )
    }
}
