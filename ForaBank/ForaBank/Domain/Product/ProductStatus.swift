//
//  ProductStatus.swift
//  ForaBank
//
//  Created by Max Gribov on 08.10.2022.
//

import Foundation

struct ProductStatus: OptionSet {
 
    let rawValue: Int

    static let active  = ProductStatus(rawValue: 1 << 0)
    static let blocked = ProductStatus(rawValue: 1 << 1)
    static let visible = ProductStatus(rawValue: 1 << 2)
}
