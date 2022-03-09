//
//  ProductData.swift
//  ForaBank
//
//  Created by Max Gribov on 01.02.2022.
//

import Foundation

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
    let ownerID: Int
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
        case accountNumber, additionalField, allowCredit, allowDebit, background, balance, branchId, currency, customName, fontDesignColor, id, largeDesign, mainField, mediumDesign, number, numberMasked, openDate, ownerID, productName, productType, smallDesign
    }
}
