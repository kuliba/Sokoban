//
//  ProductDetailsData.swift
//  ForaBank
//
//  Created by Max Gribov on 01.02.2022.
//

import Foundation

struct ProductDetailsData: Codable, Equatable {
    
    let accountNumber: String
    let bic: String
    let corrAccount: String
    let inn: String
    let kpp: String
    let payeeName: String
}
