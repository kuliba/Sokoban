//
//  AnywayServicePickerFlowState.swift
//  ForaBank
//
//  Created by Igor Malyarov on 04.08.2024.
//

struct AnywayServicePickerFlowState {
    
    let content: Content
    var destination: Destination?
}

extension AnywayServicePickerFlowState {
    
    typealias Content = PaymentProviderServicePickerModel
    
    enum Destination {
        
        case alert(Alert)
        case inflight
        case main
        case payByInstructions(Node<PaymentsViewModel>)
        case payment(Node<AnywayFlowModel>)
        case scanQR
        
        enum Alert {
            
            case connectivity
            case serverError(String)
        }
    }
}
