//
//  PaymentsTransfersFlowReducerFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 08.05.2024.
//

struct PaymentsTransfersFlowReducerFactory<LastPayment, Operator, UtilityService, Content, UtilityPaymentViewModel> {
    
    let makeUtilityPrepaymentViewModel: MakeUtilityPrepaymentViewModel
    let makeUtilityPaymentViewModel: MakeUtilityPaymentViewModel
    let makePaymentsViewModel: MakePaymentsViewModel
}

extension PaymentsTransfersFlowReducerFactory {
    
    typealias UtilityPrepaymentFlowEvent = UtilityPaymentFlowEvent<LastPayment, Operator, UtilityService>.UtilityPrepaymentFlowEvent
    typealias Payload = UtilityPrepaymentFlowEvent.UtilityPrepaymentPayload
    typealias MakeUtilityPrepaymentViewModel = (Payload) -> Content
    
    typealias MakeUtilityPaymentViewModelPayload = UtilityPrepaymentFlowEvent
        .StartPaymentSuccess.StartPaymentResponse
    typealias Notify = (PaymentStateProjection) -> Void
    typealias MakeUtilityPaymentViewModel = (MakeUtilityPaymentViewModelPayload, @escaping Notify) -> UtilityPaymentViewModel
    
    typealias CloseAction = () -> Void
    typealias MakePaymentsViewModel = (@escaping CloseAction) -> PaymentsViewModel
}
