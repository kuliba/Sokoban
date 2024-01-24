//
//  OperationResult.swift
//
//
//  Created by Дмитрий Савушкин on 07.12.2023.
//

import Foundation

public struct OperationResult: Hashable {
    
    public let result: Result
    public let title: String
    public let description: String
    public let amount: String
    public let paymentID: PaymentID
    
    public init(
        result: Result,
        title: String,
        description: String,
        amount: String,
        paymentID: PaymentID
    ) {
        self.result = result
        self.title = title
        self.description = description
        self.amount = amount
        self.paymentID = paymentID
    }
    
    public enum Result {
        
        case success
        case waiting
        case failed
    }
    
    public struct PaymentID: Hashable {
        
        public let id: Int
        
        public init(id: Int) {
            
            self.id = id
        }
    }
}
