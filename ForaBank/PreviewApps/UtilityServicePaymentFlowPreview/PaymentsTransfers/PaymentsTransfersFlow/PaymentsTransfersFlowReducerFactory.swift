//
//  PaymentsTransfersFlowReducerFactory.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 06.05.2024.
//

struct PaymentsTransfersFlowReducerFactory<LastPayment, Operator, UtilityService, Content, PaymentViewModel> {
    
    let makeUtilityPrepaymentViewModel: MakeUtilityPrepaymentViewModel
    let makePaymentViewModel: MakePaymentViewModel
}

extension PaymentsTransfersFlowReducerFactory {
    
    typealias UtilityPrepaymentFlowEvent = UtilityPaymentFlowEvent<LastPayment, Operator, UtilityService>.UtilityPrepaymentFlowEvent
    typealias Payload = UtilityPrepaymentFlowEvent.UtilityPrepaymentPayload
    typealias MakeUtilityPrepaymentViewModel = (Payload) -> Content
    
    typealias MakePaymentViewModelPayload = UtilityPrepaymentFlowEvent
        .StartPaymentSuccess.StartPaymentResponse
    typealias Notify = (PaymentStateProjection) -> Void
    typealias MakePaymentViewModel = (MakePaymentViewModelPayload, @escaping Notify) -> PaymentViewModel
}
