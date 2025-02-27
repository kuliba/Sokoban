//
//  OrderAccountResponse.swift
//
//
//  Created by Andryusina Nataly on 09.02.2025.
//

public struct OrderAccountResponse: Equatable {
    
    public let accountId: Int?
    public let accountNumber: String?
    public let paymentOperationDetailId: Int?
    public let status: Status
    
    public enum Status {
        
        case completed, inflight, rejected
    }
    
    public init(accountId: Int?, accountNumber: String?, paymentOperationDetailId: Int?, status: Status) {
        
        self.accountId = accountId
        self.accountNumber = accountNumber
        self.paymentOperationDetailId = paymentOperationDetailId
        self.status = status
    }
}
