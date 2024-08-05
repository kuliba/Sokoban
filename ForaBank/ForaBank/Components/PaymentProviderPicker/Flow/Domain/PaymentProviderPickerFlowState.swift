//
//  PaymentProviderPickerFlowState.swift
//  ForaBank
//
//  Created by Igor Malyarov on 01.08.2024.
//

struct PaymentProviderPickerFlowState<Operator, Provider> {
    
    let content: Content
    var destination: Destination?
}

extension PaymentProviderPickerFlowState {
    
    typealias Content = PaymentProviderPickerModel<SegmentedOperatorProvider>
    
    enum Destination {
        
        case addCompany
        case `operator`(Operator)
        case payByInstructions(Node<PaymentsViewModel>)
        case provider(Provider)
        case scanQR
    }
}
