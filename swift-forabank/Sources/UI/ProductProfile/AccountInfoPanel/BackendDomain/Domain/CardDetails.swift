//
//  CardDetails.swift
//  
//
//  Created by Andryusina Nataly on 05.03.2024.
//

import Foundation

public struct CardDetails: Equatable {
    
    public let accountNumber: String
    public let bic: String
    public let cardNumber: String
    public let corrAccount: String
    public let expireDate: String
    public let holderName: String
    public let inn: String
    public let kpp: String
    public let maskCardNumber: String
    public let payeeName: String
    public let info: String
    public let md5hash: String
    
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
