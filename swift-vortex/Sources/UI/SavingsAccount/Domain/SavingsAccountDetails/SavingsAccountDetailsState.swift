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
        case result(SavingsAccountDetails)
    }
}

extension SavingsAccountDetailsState {
    
    var data: SavingsAccountDetails? {
        switch status {
        case .inflight:
            return nil
            
        case let .result(result):
            return result
        }
    }
}
