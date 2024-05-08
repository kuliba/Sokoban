//
//  PaymentsTransfersReducerFactory.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 06.05.2024.
//

struct PaymentsTransfersReducerFactory<UtilityPrepaymentViewModel, PaymentViewModel> {
    
    let makeUtilityPrepaymentViewModel: MakeUtilityPrepaymentViewModel
    let makePaymentViewModel: MakePaymentViewModel
}

extension PaymentsTransfersReducerFactory {
    
    typealias Payload = UtilityPaymentFlowEvent.UtilityPrepaymentFlowEvent.UtilityPrepaymentPayload
    typealias MakeUtilityPrepaymentViewModel = (Payload) -> UtilityPrepaymentViewModel
    
    typealias MakePaymentViewModelPayload = UtilityPaymentFlowEvent.UtilityPrepaymentFlowEvent
        .StartPaymentSuccess.StartPaymentResponse
    typealias Notify = (PaymentStateProjection) -> Void
    typealias MakePaymentViewModel = (MakePaymentViewModelPayload, @escaping Notify) -> PaymentViewModel
}
