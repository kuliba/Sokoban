//
//  PaymentsTransfersFlowReducerFactory.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 06.05.2024.
//

struct PaymentsTransfersFlowReducerFactory<Content, PaymentViewModel> {
    
    let makeUtilityPrepaymentViewModel: MakeUtilityPrepaymentViewModel
    let makePaymentViewModel: MakePaymentViewModel
}

extension PaymentsTransfersFlowReducerFactory {
    
    typealias Payload = UtilityPaymentFlowEvent.UtilityPrepaymentFlowEvent.UtilityPrepaymentPayload
    typealias MakeUtilityPrepaymentViewModel = (Payload) -> Content
    
    typealias MakePaymentViewModelPayload = UtilityPaymentFlowEvent.UtilityPrepaymentFlowEvent
        .StartPaymentSuccess.StartPaymentResponse
    typealias Notify = (PaymentStateProjection) -> Void
    typealias MakePaymentViewModel = (MakePaymentViewModelPayload, @escaping Notify) -> PaymentViewModel
}
