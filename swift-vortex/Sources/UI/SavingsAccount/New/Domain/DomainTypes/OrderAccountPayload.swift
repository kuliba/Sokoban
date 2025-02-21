//
//  OrderAccountPayload.swift
//
//
//  Created by Andryusina Nataly on 20.02.2025.
//

public struct OrderAccountPayload: Equatable {
    
    public let amount: Double?
    public let cryptoVersion: String?
    public let currencyCode: Int?
    public let sourceAccountId: Int?
    public let sourceCardId: Int?
    public let verificationCode: String
}
