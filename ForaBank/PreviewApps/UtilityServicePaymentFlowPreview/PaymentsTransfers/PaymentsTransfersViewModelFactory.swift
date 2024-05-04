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
    typealias Fraud = PaymentFlowState.Modal.Fraud
    typealias FraudNotify = (Fraud) -> Void
    typealias PaymentViewModel = PaymentFlowMockViewModel
    typealias MakePaymentViewModel = (MakePaymentViewModelPayload, @escaping FraudNotify) -> PaymentViewModel
    
    typealias MakeUtilityPrepaymentViewModelCompletion = (UtilityPrepaymentViewModel) -> Void
    typealias MakeUtilityPrepaymentViewModel = (@escaping MakeUtilityPrepaymentViewModelCompletion) -> Void
}
