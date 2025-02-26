//
//  OrderCardLandingResponse.swift
//
//
//  Created by Дмитрий Савушкин on 03.12.2024.
//

import RemoteServices

public struct OrderCardLandingResponse: Equatable {
    
    public let theme: String
    public let product: Product
    public let conditions: Condition
    public let security: Security
    public let frequentlyAskedQuestions: Question
    
    public init(
        theme: String,
        product: OrderCardLandingResponse.Product,
        conditions: OrderCardLandingResponse.Condition,
        security: OrderCardLandingResponse.Security,
        frequentlyAskedQuestions: OrderCardLandingResponse.Question
    ) {
        self.theme = theme
        self.product = product
        self.conditions = conditions
        self.security = security
        self.frequentlyAskedQuestions = frequentlyAskedQuestions
    }
    
    public struct Question: Equatable {
        
        public let title: String
        public let list: [Item]
        
        public init(
            title: String,
            list: [OrderCardLandingResponse.Item]
        ) {
            self.title = title
            self.list = list
        }
    }
    
    public struct Security: Equatable {
        
        public let title: String
        public let list: [Item]
        
        public init(
            title: String,
            list: [OrderCardLandingResponse.Item]
        ) {
            self.title = title
            self.list = list
        }
    }
    
    public struct Condition: Equatable {
        
        public let title: String
        public let list: [Item]
        
        public init(
            title: String,
            list: [OrderCardLandingResponse.Item]
        ) {
            self.title = title
            self.list = list
        }
    }
    
    public struct Product: Equatable {
        
        public let title: String
        public let image: String
        public let features: [String]
        public let discount: Discount
        
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
            
            public let title: String
            public let list: [Item]
            
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
        
        public let title: String
        public let subtitle: String?
        public let md5hash: String
        
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
