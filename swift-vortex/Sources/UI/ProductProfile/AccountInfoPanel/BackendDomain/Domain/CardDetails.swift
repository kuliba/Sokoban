//
//  CardDetails.swift
//  
//
//  Created by Andryusina Nataly on 05.03.2024.
//

import Foundation

public struct CardDetails: Equatable {
    
    let accountNumber: String
    let bic: String
    let cardNumber: String
    let corrAccount: String
    let expireDate: String
    let holderName: String
    let inn: String
    let kpp: String
    let maskCardNumber: String
    let payeeName: String
    let info: String
    let md5hash: String
    
    public init(
        accountNumber: String,
        bic: String,
        cardNumber: String,
        corrAccount: String,
        expireDate: String,
        holderName: String,
        inn: String,
        kpp: String,
        maskCardNumber: String,
        payeeName: String,
        info: String,
        md5hash: String
    ) {
        self.accountNumber = accountNumber
        self.bic = bic
        self.cardNumber = cardNumber
        self.corrAccount = corrAccount
        self.expireDate = expireDate
        self.holderName = holderName
        self.inn = inn
        self.kpp = kpp
        self.maskCardNumber = maskCardNumber
        self.payeeName = payeeName
        self.info = info
        self.md5hash = md5hash
    }
}
