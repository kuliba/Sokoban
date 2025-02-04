//
//  OrderCardLandingResponse.swift
//
//
//  Created by Дмитрий Савушкин on 03.12.2024.
//

import RemoteServices

public struct OrderCardLandingResponse: Equatable {
    
    let id: String
    let theme: String
    let product: Product
    let conditions: Condition
    let security: Security
    let frequentlyAskedQuestions: Question
    
    public init(
        id: String,
        theme: String,
        product: OrderCardLandingResponse.Product,
        conditions: OrderCardLandingResponse.Condition,
        security: OrderCardLandingResponse.Security,
        frequentlyAskedQuestions: OrderCardLandingResponse.Question
    ) {
        self.id = id
        self.theme = theme
        self.product = product
        self.conditions = conditions
        self.security = security
        self.frequentlyAskedQuestions = frequentlyAskedQuestions
    }
    
    public struct Question: Equatable {
        
        let title: String
        let list: [Item]
        
        public init(
            title: String,
            list: [OrderCardLandingResponse.Item]
        ) {
            self.title = title
            self.list = list
        }
    }
    
    public struct Security: Equatable {
        
        let title: String
        let list: [Item]
        
        public init(
            title: String,
            list: [OrderCardLandingResponse.Item]
        ) {
            self.title = title
            self.list = list
        }
    }
    
    public struct Condition: Equatable {
        
        let title: String
        let list: [Item]
        
        public init(
            title: String,
            list: [OrderCardLandingResponse.Item]
        ) {
            self.title = title
            self.list = list
        }
    }
    
    public struct Product: Equatable {
        
        let title: String
        let image: String
        let features: [String]
        let discount: Discount
        
        public init(
            title: String,
            image: String,
            features: [String],
            discount: OrderCardLandingResponse.Product.Discount
        ) {
            self.title = title
            self.image = image
            self.features = features
            self.discount = discount
        }
        
        public struct Discount: Equatable {
            
            let title: String
            let list: [Item]
            
            public init(
                title: String,
                list: [OrderCardLandingResponse.Item]
            ) {
                self.title = title
                self.list = list
            }
        }
    }
    
    public struct Item: Equatable {
        
        let title: String
        let subtitle: String?
        let md5hash: String
        
        public init(
            title: String,
            subtitle: String? = nil,
            md5hash: String
        ) {
            self.title = title
            self.subtitle = subtitle
            self.md5hash = md5hash
        }
    }
}
