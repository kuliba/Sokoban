//
//  AnywayServicePickerFlowState.swift
//  ForaBank
//
//  Created by Igor Malyarov on 04.08.2024.
//

struct AnywayServicePickerFlowState {
    
    let content: Content
    var isLoading = false
    var status: Status?
}

extension AnywayServicePickerFlowState {
    
    typealias Content = PaymentProviderServicePickerModel
    
    enum Status {
        
        case alert(Alert)
        case destination(Destination)
        case outside(Outside)
        
        enum Alert {
            
            case connectivity
            case serverError(String)
        }
        
        enum Destination {
            
            case payByInstructions(Node<PaymentsViewModel>)
            case payment(Node<AnywayFlowModel>)
        }
        
        enum Outside {
            
            case addCompany
            case main
            case payments
            case scanQR
        }
    }
}
