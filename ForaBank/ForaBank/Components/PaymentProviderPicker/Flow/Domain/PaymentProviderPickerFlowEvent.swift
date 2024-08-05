//
//  PaymentProviderPickerFlowEvent.swift
//  ForaBank
//
//  Created by Igor Malyarov on 01.08.2024.
//

enum PaymentProviderPickerFlowEvent {
    
    case dismiss
    case goTo(GoTo)
    case payByInstructions
    case select(Select)
}

extension PaymentProviderPickerFlowEvent {
    
    enum GoTo {
        
        case addCompany
        case inflight
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
