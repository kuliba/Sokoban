//
//  SavingsAccountDetailsState.swift
//
//
//  Created by Andryusina Nataly on 29.11.2024.
//

import SwiftUI

public struct SavingsAccountDetailsState: Equatable {
    
    public let status: Status
    public var isExpanded: Bool = false

    public init(
        status: Status
    ) {
        self.status = status
    }
}

public extension SavingsAccountDetailsState {
    
    enum Status: Equatable {
        
        case inflight
        case failure(Kind)
        case result(SavingsAccountDetails)
    }
    
    enum Kind {
        case alert
        case informer
    }
}

extension SavingsAccountDetailsState {
    
    var data: SavingsAccountDetails? {
        switch status {
        case .inflight:
            return nil
            
        case .failure:
            return .empty
            
        case let .result(result):
            return result
        }
    }
}

extension SavingsAccountDetails {
    
    static let empty: Self = .init(
        dateNext: nil,
        dateSettlement: nil,
        dateStart: nil,
        daysLeft: nil,
        daysLeftText: nil,
        interestAmount: nil,
        interestPaid: nil,
        isNeedTopUp: nil,
        isPercentBurned: nil,
        minRest: nil,
        currencyCode: "RUB",
        progress: 0
    )
}
