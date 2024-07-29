//
//  PaymentProviderServicePickerFlowState.swift
//  ForaBank
//
//  Created by Igor Malyarov on 24.07.2024.
//

struct PaymentProviderServicePickerFlowState {
    
    var alert: Alert?
    let content: Content
    var destination: Destination?
    var isContentLoading = false
}

extension PaymentProviderServicePickerFlowState {
    
    typealias Content = PaymentProviderServicePickerModel
    
    typealias Alert = ServiceFailureAlert
    
    enum Destination {
        
        case payment(ServicePaymentBinder)
        case paymentByInstruction(PaymentsViewModel)
        
        typealias Transaction = AnywayTransactionState.Transaction
    }
}
