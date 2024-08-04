//
//  AnywayServicePickerFlowEvent.swift
//  ForaBank
//
//  Created by Igor Malyarov on 04.08.2024.
//

enum AnywayServicePickerFlowEvent: Equatable {
    
    case dismiss
    case goToMain
    case goToPayments
    case notify(PaymentProviderServicePickerResult)
    case payByInstruction
    case scanQR
}
