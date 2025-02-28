//
//  OrderAccountResponse.swift
//
//
//  Created by Andryusina Nataly on 09.02.2025.
//

import ProductSelectComponent

public struct OrderAccountResponse: Equatable {
    
    public let accountId: Int?
    public let accountNumber: String?
    public let paymentOperationDetailId: Int?
    public let product: ProductSelect.Product?
    public let openData: String?
    public let status: Status
    
    public enum Status {
        
        case completed, inflight, rejected
    }
    
    public init(
        accountId: Int?,
        accountNumber: String?,
        paymentOperationDetailId: Int?,
        product: ProductSelect.Product?,
        openData: String?,
        status: Status
    ) {
        self.accountId = accountId
        self.accountNumber = accountNumber
        self.paymentOperationDetailId = paymentOperationDetailId
        self.product = product
        self.openData = openData
        self.status = status
    }
}
