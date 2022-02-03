//
//  FastPaymentContractAttributeTypeData.swift
//  ForaBank
//
//  Created by Дмитрий on 02.02.2022.
//

import Foundation

struct FastPaymentContractAttributeTypeData: Codable, Equatable {
    
    let accountID: Int?
    let branchBIC: String?
    let branchID: Int?
    let clientID: Int?
    let flagBankDefault: FastPaymentFlag?
    let flagClientAgreementIn: FastPaymentFlag?
    let flagClientAgreementOut: FastPaymentFlag?
    let fpcontractID: Int?
    let phoneNumber: String?
}
