//
//  GetBannerCatalogListResponse.swift
//  
//
//  Created by Andryusina Nataly on 29.08.2024.
//

import Foundation

public struct GetBannerCatalogListResponse: Equatable {
    
    public let serial: String?
    public let bannerCatalogList: [Item]
    
    public init(
        serial: String?,
        bannerCatalogList: [Item]
    ) {
        self.serial = serial
        self.bannerCatalogList = bannerCatalogList
    }
    
    public struct Item: Equatable {
        
        let productName: String
        let conditions: [String]
        let imageLink: String
        let orderLink: String
        let conditionLink: String
        let action: BannerAction?

        public init(
            productName: String,
            conditions: [String],
            imageLink: String,
            orderLink: String,
            conditionLink: String,
            action: BannerAction?
        ) {
            self.productName = productName
            self.conditions = conditions
            self.imageLink = imageLink
            self.orderLink = orderLink
            self.conditionLink = conditionLink
            self.action = action
        }
    }
    
    public struct BannerAction: Equatable {
        
        let type: BannerActionType
        
        public init(
            type: BannerActionType
        ) {
            self.type = type
        }
    }
    
    public enum BannerActionType: Equatable {
        
        case openDeposit(Int)
        case depositsList
        case migTransfer(String)
        case migAuthTransfer(String)
        case contact(String)
        case depositTransfer(String)
        case landing(String)
    }
}


/*class BannerActionDepositOpen: BannerAction {
    
    //FIXME: change to Int
    let depositProductId: String
    
    private enum CodingKeys: String, CodingKey {
        
        case depositProductId = "depositProductID"
    }
    
    internal init(depositProductId: String) {
        self.depositProductId = depositProductId
        super.init(type: .openDeposit)
    }
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        depositProductId = try container.decode(String.self, forKey: .depositProductId)
        
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(depositProductId, forKey: .depositProductId)
        
        try super.encode(to: encoder)
    }
}

class BannerActionDepositsList: BannerAction {}

class BannerActionMigTransfer: BannerAction {
    
    let countryId: String
    
    private enum CodingKeys: String, CodingKey {
        
        case countryId
    }
    
    internal init(countryId: String) {
        self.countryId = countryId
        super.init(type: .migTransfer)
    }
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        countryId = try container.decode(String.self, forKey: .countryId)
        
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(countryId, forKey: .countryId)
        
        try super.encode(to: encoder)
    }
}

class BannerActionContactTransfer: BannerAction {
    
    let countryId: String
    
    private enum CodingKeys: String, CodingKey {
        
        case countryId
    }
    
    internal init(countryId: String) {
        self.countryId = countryId
        super.init(type: .contact)
    }
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        countryId = try container.decode(String.self, forKey: .countryId)
        
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(countryId, forKey: .countryId)
        
        try super.encode(to: encoder)
    }
}

class BannerActionMigAuthTransfer: BannerAction {
    
    let countryId: String
    
    private enum CodingKeys: String, CodingKey {
        
        case countryId
    }
    
    internal init(countryId: String) {
        self.countryId = countryId
        super.init(type: .contact)
    }
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        countryId = try container.decode(String.self, forKey: .countryId)
        
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(countryId, forKey: .countryId)
        
        try super.encode(to: encoder)
    }
}

class BannerActionDepositTransfer: BannerAction {
    
    let countryId: String
    
    private enum CodingKeys: String, CodingKey {
        
        case countryId
    }
    
    internal init(countryId: String) {
        self.countryId = countryId
        super.init(type: .contact)
    }
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        countryId = try container.decode(String.self, forKey: .countryId)
        
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(countryId, forKey: .countryId)
        
        try super.encode(to: encoder)
    }
}
*/
