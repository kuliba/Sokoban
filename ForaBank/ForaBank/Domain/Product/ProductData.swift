//
//  ProductData.swift
//  ForaBank
//
//  Created by Max Gribov on 01.02.2022.
//

import Foundation

struct ProductData: Equatable {

    let xlDesign: SVGImageData
    let accountNumber: String
    let additionalField: String?
    let allowCredit: Bool
    let allowDebit: Bool
    let background: [ColorData]
    let balance: Double
    let branchId: Int
    let currency: String
    let customName: String?
    let fontDesignColor: ColorData
    let id: Int
    let largeDesign: SVGImageData
    let mainField: String
    let mediumDesign: SVGImageData
    let number: String
    let numberMasked: String
    let openDate: Date
    let ownerID: Int
    let productName: String
    let productType: ProductType
    let smallDesign: SVGImageData
}

extension ProductData: Codable {
    
    private enum CodingKeys: String, CodingKey {

        case xlDesign = "XLDesign"
        case accountNumber, additionalField, allowCredit, allowDebit, background, balance, branchId, currency, customName, fontDesignColor, id, largeDesign, mainField, mediumDesign, number, numberMasked, openDate, ownerID, productName, productType, smallDesign
    }
}
