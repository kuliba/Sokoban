//
//  MakeOpenSavingsAccountPayload.swift
//  
//
//  Created by Andryusina Nataly on 25.11.2024.
//

import Foundation

public struct MakeOpenSavingsAccountPayload {
    
    public let accountID: Int?
    public let amount: Decimal?
    public let cardID: Int?
    public let cryptoVersion: String
    public let currencyCode: Int?
    public let verificationCode: String
    
    public init(
        accountID: Int?,
        amount: Decimal?,
        cardID: Int?,
        cryptoVersion: String,
        currencyCode: Int?,
        verificationCode: String
    ) {
        self.accountID = accountID
        self.amount = amount
        self.cardID = cardID
        self.cryptoVersion = cryptoVersion
        self.currencyCode = currencyCode
        self.verificationCode = verificationCode
    }
}
