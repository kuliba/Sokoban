//
//  BannerCatalogListData.swift
//  ForaBank
//
//  Created by Дмитрий on 05.03.2022.
//

import Foundation

struct BannerCatalogListData: Codable, Equatable, Identifiable, Hashable {
    
    var id: Int { hashValue }
    let productName: String
    let conditions: [String]
    let imageEndpoint: String
    let orderURL: URL?
    let conditionURL: URL?
    let action: BannerAction?
    
    internal init(
        productName: String,
        conditions: [String],
        imageEndpoint: String,
        orderURL: URL?,
        conditionURL: URL?,
        action: BannerAction?
    ) {
        self.productName = productName
        self.conditions = conditions
        self.imageEndpoint = imageEndpoint
        self.orderURL = orderURL
        self.conditionURL = conditionURL
        self.action = action
    }
    
    private enum CodingKeys : String, CodingKey, Decodable {
        
        case productName, action
        case conditions = "txtСondition"
        case imageEndpoint = "imageLink"
        case orderURL = "orderLink"
        case conditionURL = "conditionLink"
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        productName = try container.decode(String.self, forKey: .productName)
        conditions = try container.decode([String].self, forKey: .conditions)
        imageEndpoint = try container.decode(String.self, forKey: .imageEndpoint)
        orderURL = try container.decodeIfPresent(URL.self, forKey: .orderURL)
        conditionURL = try container.decodeIfPresent(URL.self, forKey: .conditionURL)
       
        if let action = try container.decodeIfPresent(BannerAction.self, forKey: .action) {
            
            switch action.type {
            case .landing:
                self.action = action
                
            case .openDeposit:
                let action = try container.decodeIfPresent(BannerActionDepositOpen.self, forKey: .action)
                self.action = action
              
            case .depositsList:
                let action = try? container.decodeIfPresent(BannerActionDepositsList.self, forKey: .action)
                self.action = action
                
            case .migTransfer:
                let action = try? container.decodeIfPresent(BannerActionMigTransfer.self, forKey: .action)
                self.action = action
                
            case .migAuthTransfer:
                let action = try? container.decodeIfPresent(BannerActionMigAuthTransfer.self, forKey: .action)
                self.action = action
                
            case .contact:
                let action = try? container.decodeIfPresent(BannerActionContactTransfer.self, forKey: .action)
                self.action = action
                
            case .depositTransfer:
                let action = try? container.decodeIfPresent(BannerActionDepositTransfer.self, forKey: .action)
                self.action = action
            }
            
        } else {
            
            self.action = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(productName, forKey: .productName)
        try container.encode(action, forKey: .action)
        try container.encode(conditions, forKey: .conditions)
        try container.encode(imageEndpoint, forKey: .imageEndpoint)
        try container.encode(orderURL, forKey: .orderURL)
        try container.encode(conditionURL, forKey: .conditionURL)
    }
}

enum BannerActionType: String, Codable, Equatable {
    
    case openDeposit = "DEPOSIT_OPEN"
    case depositsList = "DEPOSITS"
    case migTransfer = "MIG_TRANSFER"
    case migAuthTransfer = "MIG_AUTH_TRANSFER"
    case contact = "CONTACT_TRANSFER"
    case depositTransfer = "DEPOSIT_TRANSFER"
    case landing = "LANDING"
}

class BannerAction: Codable, Equatable, Hashable {
    
    let type: BannerActionType
    
    internal init(type: BannerActionType) {
        self.type = type
    }
    
    private enum CodingKeys : String, CodingKey, Decodable {
        
        case type
    }
    
    required init(from decoder: Decoder) throws {
    
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(BannerActionType.self, forKey: .type)
    }
    
    func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
    }
    
    static func == (lhs: BannerAction, rhs: BannerAction) -> Bool {
        
        lhs.type == rhs.type
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
    }
}

class BannerActionDepositOpen: BannerAction {
    
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

class BannerActionLanding: BannerAction {
    
    let target: String
    
    private enum CodingKeys: String, CodingKey {
        
        case target
    }
    
    internal init(target: String) {
        self.target = target
        super.init(type: .landing)
    }
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        target = try container.decode(String.self, forKey: .target)
        
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(target, forKey: .target)
        
        try super.encode(to: encoder)
    }
}
