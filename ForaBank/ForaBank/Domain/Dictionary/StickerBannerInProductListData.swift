//
//  StickerBannerInProductListData.swift
//  ForaBank
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
    
    var title: String {
        
        let components = productName.components(separatedBy: " ")
        return components.first ?? ""
    }
    
    var subtitle: String {
        
        let components = productName.components(separatedBy: " ")
        return components.count > 1 ? components[1] : ""
    }
}


struct CardBannerAction: Codable, Equatable {
    
    let actionType: String
    let landingDate: String
}

extension StickerBannersMyProductList {
    
    func mapper(backgroundImage: Image) -> ProductCarouselView.StickerViewModel {
        
        .init(title: title, subTitle: subtitle, backgroundImage: backgroundImage)
    }
}
