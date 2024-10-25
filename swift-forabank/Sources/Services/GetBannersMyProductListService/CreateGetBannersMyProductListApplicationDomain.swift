//
//  CreateGetBannersMyProductListApplicationDomain.swift
//
//
//  Created by Valentin Ozerov on 22.10.2024.
//

import RemoteServices

extension ResponseMapper {
    
    public struct CreateGetBannersMyProductListApplicationDomain: Equatable {
        
        public let loanBannerList: [Banner]
        public let cardBannerList: [Banner]

        public init(loanBannerList: [Banner], cardBannerList: [Banner]) {
            self.loanBannerList = loanBannerList
            self.cardBannerList = cardBannerList
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
                public let landingDate: String?
                public let target: String?
                
                public init(actionType: ActionType, landingDate: String?, target: String?) {
                    self.actionType = actionType
                    self.landingDate = landingDate
                    self.target = target
                }
                
                public enum ActionType: String, CaseIterable {
                    case openDeposit = "DEPOSIT_OPEN"
                    case depositList = "DEPOSITS"
                    case migTransfer = "MIG_TRANSFER"
                    case migAuthTransfer = "MIG_AUTH_TRANSFER"
                    case contact = "CONTACT_TRANSFER"
                    case depositTransfer = "DEPOSIT_TRANSFER"
                    case landing = "LANDING"
                    case unknown
                }
            }
        }
    }
}
