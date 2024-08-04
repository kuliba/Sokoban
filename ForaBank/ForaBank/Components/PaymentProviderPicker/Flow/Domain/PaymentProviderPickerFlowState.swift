//
//  PaymentProviderPickerFlowState.swift
//  ForaBank
//
//  Created by Igor Malyarov on 01.08.2024.
//

struct PaymentProviderPickerFlowState<Operator, Provider> {
    
    let content: Content
    var status: Status?
}

extension PaymentProviderPickerFlowState {
    
    typealias Content = PaymentProviderPickerModel<SegmentedOperatorProvider>
    
    enum Status {
        
        case `operator`(Operator)
        case outside(Outside)
        case payByInstructions(Node<PaymentsViewModel>)
        case provider(Provider)
        
        enum Outside {
            
            case addCompany
            case scanQR
        }
    }
}
