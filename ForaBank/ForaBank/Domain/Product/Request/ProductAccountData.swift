//
//  ProductAccountData.swift
//  ForaBank
//
//  Created by Дмитрий on 05.04.2022.
//

import Foundation

class ProductAccountData: ProductData {
    
    let externalId: Int
    let name: String
    let dateOpen: Date
    let status: Status
    let branchName: String?
    let miniStatement: [PaymentData]
    let detailedRatesUrl: String
    let detailedConditionUrl: String
    
    init(id: Int, productType: ProductType, number: String?, numberMasked: String?, accountNumber: String?, balance: Double?, balanceRub: Double?, currency: String, mainField: String, additionalField: String?, customName: String?, productName: String, openDate: Date?, ownerId: Int, branchId: Int?, allowCredit: Bool, allowDebit: Bool, extraLargeDesign: SVGImageData, largeDesign: SVGImageData, smallDesign: SVGImageData, fontDesignColor: ColorData, background: [ColorData], externalId: Int, name: String, dateOpen: Date, status: Status, branchName: String?, miniStatement: [PaymentData], order: Int, visibility: Bool, smallDesignMd5hash: String, smallBackgroundDesignHash: String, detailedRatesUrl: String, detailedConditionUrl: String) {
        
        self.externalId = externalId
        self.name = name
        self.dateOpen = dateOpen
        self.status = status
        self.branchName = branchName
        self.miniStatement = miniStatement
        self.detailedRatesUrl = detailedRatesUrl
        self.detailedConditionUrl = detailedConditionUrl
        
        super.init(id: id, productType: productType, number: number, numberMasked: numberMasked, accountNumber: accountNumber, balance: balance, balanceRub: balanceRub, currency: currency, mainField: mainField, additionalField: additionalField, customName: customName, productName: productName, openDate: openDate, ownerId: ownerId, branchId: branchId, allowCredit: allowCredit, allowDebit: allowDebit, extraLargeDesign: extraLargeDesign, largeDesign: largeDesign, smallDesign: smallDesign, fontDesignColor: fontDesignColor, background: background, order: order, isVisible: visibility, smallDesignMd5hash: smallDesignMd5hash, smallBackgroundDesignHash: smallBackgroundDesignHash)
    }
    
    private enum CodingKeys : String, CodingKey {
        
        case externalId = "externalID"
        case name, dateOpen, status, branchName, miniStatement, detailedRatesUrl, detailedConditionUrl
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        externalId = try container.decode(Int.self, forKey: .externalId)
        name = try container.decode(String.self, forKey: .name)
        let dateOpenValue = try container.decode(Int.self, forKey: .dateOpen)
        dateOpen = Date.dateUTC(with: dateOpenValue)
        status = try container.decode(Status.self, forKey: .status)
        branchName = try container.decodeIfPresent(String.self, forKey: .branchName)
        miniStatement = try container.decode([PaymentData].self, forKey: .miniStatement)
        detailedRatesUrl = try container.decode(String.self, forKey: .detailedRatesUrl)
        detailedConditionUrl = try container.decode(String.self, forKey: .detailedConditionUrl)
        
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(externalId, forKey: .externalId)
        try container.encode(name, forKey: .name)
        try container.encode(dateOpen.secondsSince1970UTC, forKey: .dateOpen)
        try container.encode(status, forKey: .status)
        try container.encodeIfPresent(branchName, forKey: .branchName)
        try container.encode(miniStatement, forKey: .miniStatement)
        try container.encode(detailedRatesUrl, forKey: .detailedRatesUrl)
        try container.encode(detailedConditionUrl, forKey: .detailedConditionUrl)
        
        try super.encode(to: encoder)
    }
    
    //MARK: Equitable
    
    static func == (lhs: ProductAccountData, rhs: ProductAccountData) -> Bool {
        
        return  lhs.externalId == rhs.externalId &&
        lhs.name == rhs.name &&
        lhs.dateOpen == rhs.dateOpen &&
        lhs.name == rhs.name &&
        lhs.status == rhs.status &&
        lhs.branchName == rhs.branchName &&
        lhs.miniStatement == rhs.miniStatement &&
        lhs.detailedRatesUrl == rhs.detailedRatesUrl &&
        lhs.detailedConditionUrl == rhs.detailedConditionUrl
    }
}
