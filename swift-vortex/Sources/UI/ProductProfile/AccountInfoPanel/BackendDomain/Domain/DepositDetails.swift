//
//  DepositDetails.swift
//  
//
//  Created by Andryusina Nataly on 05.03.2024.
//

import Foundation

public struct DepositDetails: Equatable {
    
    let accountNumber: String
    let bic: String
    let corrAccount: String
    let expireDate: String
    let inn: String
    let kpp: String
    let payeeName: String
    
    public init(
        accountNumber: String,
        bic: String,
        corrAccount: String,
        expireDate: String,
        inn: String,
        kpp: String,
        payeeName: String
    ) {
        self.accountNumber = accountNumber
        self.bic = bic
        self.corrAccount = corrAccount
        self.expireDate = expireDate
        self.inn = inn
        self.kpp = kpp
        self.payeeName = payeeName
    }
}
