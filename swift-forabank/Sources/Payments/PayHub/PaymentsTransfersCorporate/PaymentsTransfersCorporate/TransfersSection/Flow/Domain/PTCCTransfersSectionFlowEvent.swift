//
//  PTCCTransfersSectionFlowEvent.swift
//  
//
//  Created by Igor Malyarov on 04.09.2024.
//

public enum PTCCTransfersSectionFlowEvent<Navigation, Select> {
    
    case navigation(Navigation)
    case select(Select)
}

extension PTCCTransfersSectionFlowEvent: Equatable where Navigation: Equatable, Select: Equatable {}
