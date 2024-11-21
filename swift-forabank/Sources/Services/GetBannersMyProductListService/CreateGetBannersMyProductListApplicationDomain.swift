//
//  CreateGetBannersMyProductListApplicationDomain.swift
//
//
//  Created by Valentin Ozerov on 22.10.2024.
//

import RemoteServices

extension ResponseMapper {
    
    public struct GetBannersMyProductListResponse: Equatable {
        
        public let serial: String
        public let cardBannerList: [Banner]
        public let loanBannerList: [Banner]

        public init(serial: String, cardBannerList: [Banner], loanBannerList: [Banner]) {
            self.serial = serial
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
                
                public let actionType: String
                public let target: String?
                
                public init(actionType: String, target: String?) {
                    self.actionType = actionType
                    self.target = target
                }
            }
        }
    }
}
