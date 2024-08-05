//
//  PaymentProviderPickerFlowState.swift
//  ForaBank
//
//  Created by Igor Malyarov on 01.08.2024.
//

struct PaymentProviderPickerFlowState {
    
    let content: Content
    var isLoading = false
    var status: Status?
}

extension PaymentProviderPickerFlowState {
    
    typealias Content = PaymentProviderPickerModel<SegmentedOperatorProvider>
    
    enum Status {
        
        case destination(Destination)
        case outside(Outside)
        
        enum Destination {
            
            case payByInstructions(Node<PaymentsViewModel>)
            case payments(Node<PaymentsViewModel>)
            case servicePicker(Node<AnywayServicePickerFlowModel>)
        }
        
        enum Outside {
            
            case addCompany
            case main
            case payments
            case scanQR
        }
        
        typealias Operator = SegmentedOperatorData
        typealias Provider = SegmentedProvider
    }
}
