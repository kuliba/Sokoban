//
//  ProductData.swift
//  ForaBank
//
//  Created by Max Gribov on 01.02.2022.
//

import Foundation
import SwiftUI

struct ProductData: Equatable, Identifiable {

    let id: Int
    
    let productType: ProductType
    
    let number: String // 4444555566661122
    let numberMasked: String //4444-XXXX-XXXX-1122
    let accountNumber: String // 40817810000000000001
    
    let balance: Double
    let balanceRub: Double?
    let currency: String // example: RUB
    
    let mainField: String // example: Gold
    let additionalField: String? // example: Зарплатная
    let customName: String? // example: Моя карта
    let productName: String // example: VISA REWARDS R-5

    let openDate: Date
    let ownerId: Int
    let branchId: Int
    
    let allowCredit: Bool
    let allowDebit: Bool

    let extraLargeDesign: SVGImageData
    let largeDesign: SVGImageData
    let mediumDesign: SVGImageData
    let smallDesign: SVGImageData
    let fontDesignColor: ColorData
    let background: [ColorData]
}

extension ProductData: Codable {
    
    private enum CodingKeys: String, CodingKey {

        case extraLargeDesign = "XLDesign"
        case balanceRub = "balanceRUB"
        case ownerId = "ownerID"
        case accountNumber, additionalField, allowCredit, allowDebit, background, balance, branchId, currency, customName, fontDesignColor, id, largeDesign, mainField, mediumDesign, number, numberMasked, openDate, productName, productType, smallDesign
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.productType = try container.decode(ProductType.self, forKey: .productType)
        self.number = try container.decode(String.self, forKey: .number)
        self.numberMasked = try container.decode(String.self, forKey: .numberMasked)
        self.accountNumber = try container.decode(String.self, forKey: .accountNumber)
        self.balance = try container.decode(Double.self, forKey: .balance)
        self.balanceRub = try container.decodeIfPresent(Double.self, forKey: .balanceRub)
        self.currency = try container.decode(String.self, forKey: .currency)
        self.mainField = try container.decode(String.self, forKey: .mainField)
        self.additionalField = try container.decodeIfPresent(String.self, forKey: .additionalField)
        self.customName = try container.decodeIfPresent(String.self, forKey: .customName)
        self.productName = try container.decode(String.self, forKey: .productName)
        let openDateValue = try container.decode(Int.self, forKey: .openDate)
        self.openDate = Date(timeIntervalSince1970: TimeInterval(openDateValue / 1000))
        self.ownerId = try container.decode(Int.self, forKey: .ownerId)
        self.branchId = try container.decode(Int.self, forKey: .branchId)
        self.allowCredit = try container.decode(Bool.self, forKey: .allowCredit)
        self.allowDebit = try container.decode(Bool.self, forKey: .allowDebit)
        self.extraLargeDesign = try container.decode(SVGImageData.self, forKey: .extraLargeDesign)
        self.largeDesign = try container.decode(SVGImageData.self, forKey: .largeDesign)
        self.mediumDesign = try container.decode(SVGImageData.self, forKey: .mediumDesign)
        self.smallDesign = try container.decode(SVGImageData.self, forKey: .smallDesign)
        self.fontDesignColor = try container.decode(ColorData.self, forKey: .fontDesignColor)
        self.background = try container.decode([ColorData].self, forKey: .background)
    }
    
    func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(productType, forKey: .productType)
        try container.encode(number, forKey: .number)
        try container.encode(numberMasked, forKey: .numberMasked)
        try container.encode(accountNumber, forKey: .accountNumber)
        try container.encode(balance, forKey: .balance)
        try container.encodeIfPresent(balanceRub, forKey: .balanceRub)
        try container.encode(currency, forKey: .currency)
        try container.encode(mainField, forKey: .mainField)
        try container.encodeIfPresent(additionalField, forKey: .additionalField)
        try container.encodeIfPresent(customName, forKey: .customName)
        try container.encode(productName, forKey: .productName)
        try container.encode(Int(openDate.timeIntervalSince1970) * 1000, forKey: .openDate)
        try container.encode(ownerId, forKey: .ownerId)
        try container.encode(branchId, forKey: .branchId)
        try container.encode(allowCredit, forKey: .allowCredit)
        try container.encode(allowDebit, forKey: .allowDebit)
        try container.encode(extraLargeDesign, forKey: .extraLargeDesign)
        try container.encode(largeDesign, forKey: .largeDesign)
        try container.encode(mediumDesign, forKey: .mediumDesign)
        try container.encode(smallDesign, forKey: .smallDesign)
        try container.encode(fontDesignColor, forKey: .fontDesignColor)
        try container.encode(background, forKey: .background)
    }
}

extension ProductData {
    
    func updated(with params: ProductDynamicParams) -> ProductData {
        
        guard self.id == params.id, self.productType == params.type else {
            return self
        }
        
        return ProductData(id: id, productType: productType, number: number, numberMasked: numberMasked, accountNumber: accountNumber, balance: params.dynamicParams.balance, balanceRub: params.dynamicParams.balanceRUB, currency: currency, mainField: mainField, additionalField: additionalField, customName: params.dynamicParams.customName, productName: productName, openDate: openDate, ownerId: ownerId, branchId: branchId, allowCredit: allowCredit, allowDebit: allowDebit, extraLargeDesign: extraLargeDesign, largeDesign: largeDesign, mediumDesign: mediumDesign, smallDesign: smallDesign, fontDesignColor: fontDesignColor, background: background)
    }
}
