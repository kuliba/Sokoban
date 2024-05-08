//
//  PaymentsTransfersReducerFactory.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 06.05.2024.
//

struct PaymentsTransfersReducerFactory {
    
    let makeUtilityPrepaymentViewModel: MakeUtilityPrepaymentViewModel
    let makePaymentViewModel: MakePaymentViewModel
}

extension PaymentsTransfersReducerFactory {
    
    typealias Payload = UtilityPaymentFlowEvent.UtilityPrepaymentFlowEvent.UtilityPrepaymentPayload
    typealias MakeUtilityPrepaymentViewModel = (Payload) -> UtilityPrepaymentViewModel
    
    typealias MakePaymentViewModelPayload = UtilityPaymentFlowEvent.UtilityPrepaymentFlowEvent
        .StartPaymentSuccess.StartPaymentResponse
    #warning("move from factory - but where?")
    enum PaymentStateProjection: Equatable {
        
        case completed
        case errorMessage(String)
        case fraud(Fraud)
    }
    typealias Notify = (PaymentStateProjection) -> Void
    typealias PaymentViewModel = ObservingPaymentFlowMockViewModel
    typealias MakePaymentViewModel = (MakePaymentViewModelPayload, @escaping Notify) -> PaymentViewModel
}

extension PaymentsTransfersReducerFactory.PaymentStateProjection {
    
    typealias Fraud = UtilityServicePaymentFlowState.Modal.Fraud
}

