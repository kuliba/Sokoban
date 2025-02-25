//
//  OrderAccountResponse.swift
//
//
//  Created by Andryusina Nataly on 09.02.2025.
//

public struct OrderAccountResponse: Equatable {
    
    public let accountId: String?
    public let paymentOperationDetailId: Int?
    public let status: Status
    
    public enum Status {
        
        case completed, inflight, rejected
    }
    
    public init(accountId: String?, paymentOperationDetailId: Int?, status: Status) {
        self.accountId = accountId
        self.paymentOperationDetailId = paymentOperationDetailId
        self.status = status
    }
}
