//
//  AccountDetails.swift
//  
//
//  Created by Andryusina Nataly on 05.03.2024.
//

import Foundation

public struct AccountDetails: Equatable {
    
    let accountNumber: String
    let bankName: String
    let bic: String
    let corrAccount: String
    let inn: String
    let kpp: String
    let payeeName: String
    
    public init(
        accountNumber: String,
        bankName: String,
        bic: String,
        corrAccount: String,
        inn: String,
        kpp: String,
        payeeName: String
    ) {
        self.accountNumber = accountNumber
        self.bankName = bankName
        self.bic = bic
        self.corrAccount = corrAccount
        self.inn = inn
        self.kpp = kpp
        self.payeeName = payeeName
    }
}
