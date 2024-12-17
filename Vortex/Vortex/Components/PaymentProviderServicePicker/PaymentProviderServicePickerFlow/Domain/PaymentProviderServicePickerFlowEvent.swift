//
//  PaymentProviderServicePickerFlowEvent.swift
//  ForaBank
//
//  Created by Igor Malyarov on 24.07.2024.
//

enum PaymentProviderServicePickerFlowEvent {
    
    case dismissDestination
    case payByInstructionTap
    case payByInstruction(PaymentsViewModel)
}
