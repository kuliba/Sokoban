//
//  StickerBannerInProductListData.swift
//  Vortex
//
//  Created by Andrew Kurdin on 25.10.2023.
//

import SwiftUI

struct StickerResponseData: Codable {
    
    let serial: String
    let cardBannerList: [CardBannerList]
    let depositBannerList: [DepositBannerList]
    let accountBannerList: [AccountBannerList]
    let loanBannerList: [LoanBannerList]
}

struct DepositBannerList: Codable {}
struct AccountBannerList: Codable {}
struct LoanBannerList: Codable {}

struct CardBannerList: Codable, Equatable {
    
    let productName: String
    let link: String
    let md5hash: String
    let action: CardBannerAction?
}

struct CardBannerAction: Codable, Equatable {
    
    let actionType: String
    let landingDate: String
}

extension CardBannerList {
    
    func mapper(
        onTap: @escaping () -> Void,
        onHide: @escaping () -> Void
    ) -> AdditionalProductViewModel {
        
        .init(
            md5Hash: md5hash,
            productType: .card,
            promoItem: .sticker,
            onTap: onTap,
            onHide: onHide
        )
    }
}
