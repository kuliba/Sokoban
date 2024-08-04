//
//  PaymentProviderPickerFlowState.swift
//  ForaBank
//
//  Created by Igor Malyarov on 01.08.2024.
//

struct PaymentProviderPickerFlowState {
    
    let content: Content
    var status: Status?
}

extension PaymentProviderPickerFlowState {
    
    typealias Content = PaymentProviderPickerModel<SegmentedOperatorProvider>
    
    enum Status {
        
        case destination(Destination)
        case outside(Outside)
        
        enum Destination {
            
            case `operator`(Operator)
            case payByInstructions(Node<PaymentsViewModel>)
            case provider(Provider)
        }
        
        enum Outside {
            
            case addCompany
            case scanQR
        }
        
        typealias Operator = SegmentedOperatorData
        typealias Provider = SegmentedProvider
    }
}
