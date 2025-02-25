//
//  GetSavingsAccountInfoResponse.swift
//  
//
//  Created by Andryusina Nataly on 25.02.2025.
//

import Foundation

public struct GetSavingsAccountInfoResponse: Equatable {
    
    public let dateNext: String?
    public let interestAmount: Double?
    public let interestPaid: Double?
    public let minRest: Double?
    
    public init(dateNext: String?, interestAmount: Double?, interestPaid: Double?, minRest: Double?) {
        self.dateNext = dateNext
        self.interestAmount = interestAmount
        self.interestPaid = interestPaid
        self.minRest = minRest
    }
}
