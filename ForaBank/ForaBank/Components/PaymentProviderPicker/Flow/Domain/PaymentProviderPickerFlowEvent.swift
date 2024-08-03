//
//  PaymentProviderPickerFlowEvent.swift
//  ForaBank
//
//  Created by Igor Malyarov on 01.08.2024.
//

enum PaymentProviderPickerFlowEvent<Operator, Provider> {
    
    case addCompany
    case dismiss
    case `operator`(Operator)
    case payByInstructions
    case provider(Provider)
    case scanQR
}
