//
//  ProductTemplateData.swift
//  ForaBank
//
//  Created by Max Gribov on 01.02.2022.
//

import Foundation

struct ProductTemplateData: Codable, Equatable, Identifiable {
    
    let currency: String
    let customName: String
    let id: Int
    let numberMask: String
    let paymentSystemImage: SVGImageData?
    let smallDesign: SVGImageData
    let type: ProductType
}

extension ProductTemplateData {
    
    var numberMaskSuffix: String {
        
        self.numberMask.suffix(4).description
    }
}

// MARK: Stub data

extension ProductTemplateData {
    
    static func productTemplateStub() -> ProductTemplateData {
        
        return .init(
            currency: "Rub",
            customName: "customName",
            id: 1,
            numberMask: "cardNumber",
            paymentSystemImage: nil,
            smallDesign: .init(description: ""),
            type: .card)
    }
}
