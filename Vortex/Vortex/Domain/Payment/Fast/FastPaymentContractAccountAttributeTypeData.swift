//
//  FastPaymentContractAccountAttributeTypeData.swift
//  ForaBank
//
//  Created by Дмитрий on 02.02.2022.
//

import Foundation

struct FastPaymentContractAccountAttributeTypeData: Codable, Equatable {
    
    let accountId: Int?
    let accountNumber: String?
    let flagPossibAddAccount: FastPaymentFlag?
    let maxAddAccount: Double?
    let minAddAccount: Double?
    
    private enum CodingKeys: String, CodingKey {

        case accountId = "accountID"
        case accountNumber, flagPossibAddAccount, maxAddAccount, minAddAccount
    }
}
