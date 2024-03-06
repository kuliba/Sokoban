//
//  AccountDetails.swift
//  
//
//  Created by Andryusina Nataly on 05.03.2024.
//

import Foundation

public struct AccountDetails: Equatable {
    
    public let accountNumber: String
    public let bic: String
    public let corrAccount: String
    public let inn: String
    public let kpp: String
    public let payeeName: String
    
    public init(
        accountNumber: String,
        bic: String,
        corrAccount: String,
        inn: String,
        kpp: String,
        payeeName: String
    ) {
        self.accountNumber = accountNumber
        self.bic = bic
        self.corrAccount = corrAccount
        self.inn = inn
        self.kpp = kpp
        self.payeeName = payeeName
    }
}
