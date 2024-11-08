//
//  CreateGetBannersMyProductListApplicationDomain.swift
//
//
//  Created by Valentin Ozerov on 22.10.2024.
//

import RemoteServices

extension ResponseMapper {
    
    public struct CreateGetBannersMyProductListApplicationDomain: Equatable {
        
        public let cardBannerList: [Banner]
        public let loanBannerList: [Banner]

        public init(cardBannerList: [Banner], loanBannerList: [Banner]) {
            self.cardBannerList = cardBannerList
            self.loanBannerList = loanBannerList
        }
        
        public struct Banner: Equatable {
            
            public let productName: String
            public let link: String
            public let md5hash: String
            public let action: Action?
            
            public init(productName: String, link: String, md5hash: String, action: Action?) {

                self.productName = productName
                self.link = link
                self.md5hash = md5hash
                self.action = action
            }
            
            public struct Action: Equatable {
                
                public let actionType: ActionType
                public let landingData: String?
                public let target: String?
                
                public init(actionType: ActionType, landingData: String?, target: String?) {
                    self.actionType = actionType
                    self.landingData = landingData
                    self.target = target
                }
                
                public enum ActionType {
                    case openDeposit
                    case depositList
                    case migTransfer
                    case migAuthTransfer
                    case contact
                    case depositTransfer
                    case landing
                    case unknown
                }
            }
        }
    }
}
