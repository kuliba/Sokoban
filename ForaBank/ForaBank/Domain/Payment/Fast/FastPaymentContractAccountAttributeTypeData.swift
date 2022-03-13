//
//  FastPaymentContractAccountAttributeTypeData.swift
//  ForaBank
//
//  Created by Дмитрий on 02.02.2022.
//

import Foundation

struct FastPaymentContractAccountAttributeTypeData: Codable, Equatable {
    
    let accountID: Int?
    let accountNumber: String?
    let flagPossibAddAccount: FastPaymentFlag?
    let maxAddAccount: Double?
    let minAddAccount: Double?
}
