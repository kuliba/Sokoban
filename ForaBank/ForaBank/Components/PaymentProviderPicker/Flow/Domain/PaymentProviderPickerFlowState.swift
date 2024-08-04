//
//  PaymentProviderPickerFlowState.swift
//  ForaBank
//
//  Created by Igor Malyarov on 01.08.2024.
//

struct PaymentProviderPickerFlowState<Operator, Provider> {
    
    let content: Content
    var destination: Status?
}

extension PaymentProviderPickerFlowState {
    
    typealias Content = PaymentProviderPickerModel<SegmentedOperatorProvider>
    
    enum Status {
        
        case addCompany
        case `operator`(Operator)
        case payByInstructions(Node<PaymentsViewModel>)
        case provider(Provider)
        case scanQR
    }
}
