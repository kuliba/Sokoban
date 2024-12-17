//
//  ProductDynamicParams.swift
//  ForaBank
//
//  Created by Max Gribov on 09.03.2022.
//

import Foundation

class ProductDynamicParamsData: Codable, Hashable {
    
    let balance: Double
    let balanceRub: Double?
    let customName: String?
    
    private enum CodingKeys: String, CodingKey {
        
        case balanceRub = "balanceRUB"
        case balance, customName
    }
    
    internal init(balance: Double, balanceRub: Double?, customName: String?) {
        
        self.balance = balance
        self.balanceRub = balanceRub
        self.customName = customName
        
    }
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        balance = try container.decode(Double.self, forKey: .balance)
        balanceRub = try container.decodeIfPresent(Double.self, forKey: .balanceRub)
        customName = try container.decodeIfPresent(String.self, forKey: .customName)
    }
    
    func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(balance, forKey: .balance)
        try container.encode(balanceRub, forKey: .balanceRub)
        try container.encode(customName, forKey: .customName)
    }
    
    static func == (lhs: ProductDynamicParamsData, rhs: ProductDynamicParamsData) -> Bool {
        
        return lhs.balance == rhs.balance
    }
    
    func hash(into hasher: inout Hasher) {
        
        hasher.combine(balance)
    }
}

class CardDynamicParams: ProductDynamicParamsData {
    
    let status: Status?
    let debtAmount: Double?
    let totalDebtAmount: Double?
    let statusPc: ProductData.StatusPC
    
    internal init(id: UUID = UUID(), balance: Double, balanceRub: Double?, customName: String?, status: Status?, debtAmount: Double?, totalDebtAmount: Double?, statusPc: ProductData.StatusPC) {
        
        self.status = status
        self.debtAmount = debtAmount
        self.totalDebtAmount = totalDebtAmount
        self.statusPc = statusPc
        
        super.init(balance: balance, balanceRub: balanceRub, customName: customName)
    }
    
    private enum CodingKeys: String, CodingKey {
        
        case statusPc = "statusPC"
        case status, debtAmount, totalDebtAmount
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        status = try container.decodeIfPresent(Status.self, forKey: .status)
        debtAmount = try container.decodeIfPresent(Double.self, forKey: .debtAmount)
        totalDebtAmount = try container.decodeIfPresent(Double.self, forKey: .totalDebtAmount)
        statusPc = try container.decode(ProductData.StatusPC.self, forKey: .statusPc)
        
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(status, forKey: .status)
        try container.encodeIfPresent(debtAmount, forKey: .debtAmount)
        try container.encodeIfPresent(totalDebtAmount, forKey: .totalDebtAmount)
        try container.encode(statusPc.rawValue, forKey: .statusPc)
        
        try super.encode(to: encoder)
    }
}

class AccountDynamicParams: ProductDynamicParamsData {
    
    let status: Status
    
    internal init(id: UUID = UUID(), balance: Double, balanceRub: Double?, customName: String?, status: Status) {
        
        self.status = status
        
        super.init(balance: balance, balanceRub: balanceRub, customName: customName)
    }
    
    private enum CodingKeys: String, CodingKey {
        
        case status
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        status = try container.decode(Status.self, forKey: .status)
        
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(status, forKey: .status)
        
        try super.encode(to: encoder)
    }
}
