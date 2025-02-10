//
//  OrderCardPayload.swift
//  
//
//  Created by Igor Malyarov on 09.02.2025.
//

public struct OrderCardPayload: Equatable {
    
    public let requestID: String
    public let cardApplicationCardType: String
    public let cardProductExtID: String
    public let cardProductName: String
    public let smsInfo: Bool
    public let verificationCode: String
}
