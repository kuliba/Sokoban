//
//  StatementDetailContent.swift
//
//
//  Created by Igor Malyarov on 23.02.2025.
//

public struct StatementDetailContent: Equatable {
    
    public let formattedAmount: String?
    public let formattedDate: String?
    public let merchantLogo: String?
    public let merchantName: String?
    public let purpose: String?
    public let status: Status
    
    public init(
        formattedAmount: String?,
        formattedDate: String?,
        merchantLogo: String?,
        merchantName: String?,
        purpose: String?,
        status: Status
    ) {
        self.formattedAmount = formattedAmount
        self.formattedDate = formattedDate
        self.merchantLogo = merchantLogo
        self.merchantName = merchantName
        self.purpose = purpose
        self.status = status
    }
}

extension StatementDetailContent {
    
    public enum Status {
        
        case completed, inflight, rejected
    }
}
