//
//  SegmentedPaymentProviderPickerFlowEvent.swift
//  ForaBank
//
//  Created by Igor Malyarov on 01.08.2024.
//

enum SegmentedPaymentProviderPickerFlowEvent {
    
    case dismiss
    case isLoading(Bool)
    case goTo(GoTo)
    case payByInstructions
    case select(Select)
}

extension SegmentedPaymentProviderPickerFlowEvent {
    
    enum GoTo {
        
        case addCompany
        case main
        case payments
        case scanQR
    }
    
    enum Select {
        
        case `operator`(Operator)
        case provider(Provider)
        
        typealias Operator = SegmentedOperatorData
        typealias Provider = SegmentedProvider
    }
}
