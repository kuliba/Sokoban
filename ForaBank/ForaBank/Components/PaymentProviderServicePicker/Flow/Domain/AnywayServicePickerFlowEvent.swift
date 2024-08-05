//
//  AnywayServicePickerFlowEvent.swift
//  ForaBank
//
//  Created by Igor Malyarov on 04.08.2024.
//

enum AnywayServicePickerFlowEvent: Equatable {
    
    case dismiss
    case goTo(GoTo)
    case notify(PaymentProviderServicePickerResult)
    case payByInstruction
    
    enum GoTo {
        
        case addCompany
        case main
        case payments
        case scanQR
    }
}
