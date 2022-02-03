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
