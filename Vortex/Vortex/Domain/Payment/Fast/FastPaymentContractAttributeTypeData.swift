//
//  FastPaymentContractAttributeTypeData.swift
//  ForaBank
//
//  Created by Дмитрий on 02.02.2022.
//

import Foundation

struct FastPaymentContractAttributeTypeData: Codable, Equatable {
    
    let accountId: Int?
    let branchBic: String?
    let branchId: Int?
    let clientId: Int?
    let flagBankDefault: FastPaymentFlag?
    let flagClientAgreementIn: FastPaymentFlag?
    let flagClientAgreementOut: FastPaymentFlag?
    let fpcontractId: Int?
    let phoneNumber: String?
    
    private enum CodingKeys: String, CodingKey {
    
        case accountId = "accountID"
        case branchBic = "branchBIC"
        case branchId = "branchID"
        case clientId = "clientID"
        case fpcontractId = "fpcontractID"
        case flagBankDefault, flagClientAgreementIn, flagClientAgreementOut, phoneNumber
    }
}
