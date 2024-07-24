//
//  PaymentProviderServicePickerFlowEvent.swift
//  ForaBank
//
//  Created by Igor Malyarov on 24.07.2024.
//

enum PaymentProviderServicePickerFlowEvent {
    
    case dismissPaymentByInstruction
    case payByInstructionTap
    case payByInstruction(PaymentsViewModel)
}
