//
//  SegmentedPaymentProviderPickerFlowState.swift
//  Vortex
//
//  Created by Igor Malyarov on 01.08.2024.
//

struct SegmentedPaymentProviderPickerFlowState {
    
    let content: Content
    
    var isLoading = false
    var navigation: Navigation?
}

extension SegmentedPaymentProviderPickerFlowState {
    
    typealias Content = SegmentedPaymentProviderPickerState<SegmentedOperatorProvider>
    
    enum Navigation {
        
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
