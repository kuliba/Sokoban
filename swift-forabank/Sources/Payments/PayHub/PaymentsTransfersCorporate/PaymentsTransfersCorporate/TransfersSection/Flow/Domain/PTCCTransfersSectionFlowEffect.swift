//
//  PTCCTransfersSectionFlowEffect.swift
//  
//
//  Created by Igor Malyarov on 04.09.2024.
//

public enum PTCCTransfersSectionFlowEffect<Select> {
    
    case select(Select)
}

extension PTCCTransfersSectionFlowEffect: Equatable where Select: Equatable {}
