//
//  PaymentsTransfersViewModelFactory.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 03.05.2024.
//

struct PaymentsTransfersViewModelFactory {
    
    let makePaymentViewModel: MakePaymentViewModel
    let makeUtilityPrepaymentViewModel: MakeUtilityPrepaymentViewModel
}

extension PaymentsTransfersViewModelFactory {
    
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
    
    typealias MakeUtilityPrepaymentViewModelCompletion = (UtilityPrepaymentViewModel) -> Void
    typealias MakeUtilityPrepaymentViewModel = (@escaping MakeUtilityPrepaymentViewModelCompletion) -> Void
}

extension PaymentsTransfersViewModelFactory.PaymentStateProjection {
    
    typealias Fraud = UtilityServicePaymentFlowState.Modal.Fraud
}
