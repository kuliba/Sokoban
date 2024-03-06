//
//  DepositDetails.swift
//  
//
//  Created by Andryusina Nataly on 05.03.2024.
//

import Foundation

public struct DepositDetails: Equatable {
    
    public let accountNumber: String
    public let bic: String
    public let corrAccount: String
    public let expireDate: String
    public let inn: String
    public let kpp: String
    public let payeeName: String
    
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
