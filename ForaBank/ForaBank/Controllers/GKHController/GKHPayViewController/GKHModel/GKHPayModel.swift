//
//  GKHPayModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 12.08.2021.
//

import Foundation

// MARK: - GKHPayModel

struct GKHPayModel {
    var number, numberMasked: String?
    var balance: Double?
    var currency, productType, productName: String?
    var ownerID: Int?
    var accountNumber: String?
    var allowDebit, allowCredit: Bool?
    var customName: String?
    var cardID: Int?
    var name: String?
    var validThru: Int?
    var status, holderName, product, branch: String?
    var id: Int?
    
    init(_ cardData: GetProductListDatum) {
        
    }
}
