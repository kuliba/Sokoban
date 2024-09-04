//
//  PTCCTransfersSectionFlowState.swift
//
//
//  Created by Igor Malyarov on 04.09.2024.
//

public struct PTCCTransfersSectionFlowState<Navigation> {
    
    public var navigation: Navigation?
    
    public init(
        navigation: Navigation? = nil
    ) {
        self.navigation = navigation
    }
}

extension PTCCTransfersSectionFlowState: Equatable where Navigation: Equatable {}
