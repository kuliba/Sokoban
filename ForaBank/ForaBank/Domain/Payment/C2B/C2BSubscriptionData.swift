//
//  C2BSubscriptionData.swift
//  ForaBank
//
//  Created by Max Gribov on 30.01.2023.
//

import Foundation

struct C2BSubscriptionData: Decodable, Equatable {
    
    let operationStatus: Status
    let title: String
    let brandIcon: String
    let brandName: String
    let legalName: String?
    let redirectUrl: URL?
}

extension C2BSubscriptionData {
    
    enum Status: String, Decodable, Equatable, Unknownable {
        
        case complete = "COMPLETE"
        case rejected = "REJECTED"
        case unknown
    }
}

struct C2BSubscription: Decodable, Equatable {
    
    let title: String
    let subscriptionType: SubscriptionType
    let emptySearch: String?
    let emptyList: [String]?
    let list: [ProductSubscription]?
    
    struct ProductSubscription: Decodable, Equatable {
        
        let productId: String
        let productType: ProductType
        let productTitle: String
        let subscriptions: [Subscription]
        
        struct Subscription: Decodable, Equatable {
            
            let subscriptionToken: String
            let brandIcon: String
            let brandName: String
            let subscriptionPurpose: String
            let cancelAlert: String
            
        }
        
        enum ProductType: String, CodingKey, Decodable {
            
            case card = "CARD"
            case account = "ACCOUNT"
        }
    }
    
    enum SubscriptionType: String, CodingKey, Decodable {
        
        case control = "SUBSCRIPTION_CONTROL"
        case empty = "SUBSCRIPTION_EMPTY"
    }
}

extension C2BSubscription.ProductSubscription {
    
    enum CodingKeys: String, CodingKey {
        
        case productId, productType, productTitle
        case subscriptions = "subscription"
    }
}

struct BaseScenarioQrParameter: Equatable {
    
    let subscriptionToken: String
    let parameters: [AnyPaymentParameter]
    let required: [String]
}

//MARK: - Decodable

extension BaseScenarioQrParameter: Decodable {
    
    enum CodingKeys : String, CodingKey {
        
        case subscriptionToken, parameters, required
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.subscriptionToken = try container.decode(String.self, forKey: .subscriptionToken)
        self.parameters = try AnyPaymentParameter.decode(container: try container.nestedUnkeyedContainer(forKey: .parameters))
        self.required = try container.decode([String].self, forKey: .required)
    }
}
