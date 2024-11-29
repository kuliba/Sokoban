//
//  CollateralLoanLandingGetShowcaseData.swift
//  swift-forabank
//
//  Created by Valentin Ozerov on 07.10.2024.
//

import RemoteServices

extension ResponseMapper {
    
    public struct GetShowcaseData: Equatable {

        public let serial: String
        public let products: [Product]
        
        public init(serial: String, products: [Product]) {
            self.serial = serial
            self.products = products
        }
        
        public struct Product: Equatable {

            public let theme: Theme
            public let name: String
            public let terms: String
            public let landingId: String
            public let image: String
            public let keyMarketingParams: KeyMarketingParams
            public let features: Features
            
            public enum Theme: String {

                case gray
                case white
                case unknown
            }
            
            public init(
                theme: Theme,
                name: String,
                terms: String,
                landingId: String,
                image: String,
                keyMarketingParams: KeyMarketingParams,
                features: Features
            ) {
                self.theme = theme
                self.name = name
                self.terms = terms
                self.landingId = landingId
                self.image = image
                self.keyMarketingParams = keyMarketingParams
                self.features = features
            }
            
            public struct KeyMarketingParams: Equatable {

                public let rate: String
                public let amount: String
                public let term: String
                
                public init(rate: String, amount: String, term: String) {
                    self.rate = rate
                    self.amount = amount
                    self.term = term
                }
            }
            
            public struct Features: Equatable {

                public let header: String?
                public let list: [List]
                
                public init(header: String?, list: [List]) {
                    self.header = header
                    self.list = list
                }
                
                public struct List: Equatable {
                    
                    public let bullet: Bool
                    public let text: String
                    
                    public init(bullet: Bool, text: String) {
                        self.bullet = bullet
                        self.text = text
                    }
                }
            }
        }
    }
}
