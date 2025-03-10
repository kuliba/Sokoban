//
//  CardShowCaseResponse.swift
//
//
//  Created by Дмитрий Савушкин on 10.03.2025.
//

public struct CardShowCaseResponse: Equatable {
    
    public let products: [Product]
    
    public init(
        products: [CardShowCaseResponse.Product]
    ) {
        self.products = products
    }
    
    public struct Product: Equatable {
        
        let theme: String
        let name: [Name]
        let features: Features
        let image: String
        let terms: String
        let cardShowcaseAction: Action
        
        public init(
            theme: String,
            name: [Name],
            features: Features,
            image: String,
            terms: String,
            cardShowcaseAction: Action
        ) {
            self.theme = theme
            self.name = name
            self.features = features
            self.image = image
            self.terms = terms
            self.cardShowcaseAction = cardShowcaseAction
        }
        
        public struct Action: Equatable {
            
            let type: String
            let target: String
            let fallbackUrl: String?
            
            public init(
                type: String,
                target: String,
                fallbackUrl: String? = nil
            ) {
                self.type = type
                self.target = target
                self.fallbackUrl = fallbackUrl
            }
        }
        
        public struct Features: Equatable {
            
            let header: String?
            let list: [Item]
            
            public init(
                header: String? = nil,
                list: [Item]
            ) {
                self.header = header
                self.list = list
            }
            
            public struct Item: Equatable {
                
                let bullet: Bool
                let text: String
                
                public init(
                    bullet: Bool,
                    text: String
                ) {
                    self.bullet = bullet
                    self.text = text
                }
            }
        }
        
        public struct Name: Equatable {
            
            let text: String
            let isBold: Bool
            
            public init(
                text: String,
                isBold: Bool
            ) {
                self.text = text
                self.isBold = isBold
            }
        }
    }
}
