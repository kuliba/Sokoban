//
//  CardShowCaseResponse.swift
//
//
//  Created by Дмитрий Савушкин on 10.03.2025.
//

public struct CardShowCaseResponse: Equatable {
    
    public let products: [Product]
    
    public struct Product: Equatable {
        
        let theme: String
        let name: [Name]
        let features: Features
        let image: String
        let terms: String
        let cardShowcaseAction: Action
        
        public struct Action: Equatable {
        
            let type: String
            let target: String
            let fallbackUrl: String?
        }
        
        public struct Features: Equatable {
            
            let list: [Item]
            
            public struct Item: Equatable {
                
                let bullet: Bool
                let text: String
            }
        }
        
        public struct Name: Equatable {
            
            let text: String
            let isBold: Bool
        }
    }
}
