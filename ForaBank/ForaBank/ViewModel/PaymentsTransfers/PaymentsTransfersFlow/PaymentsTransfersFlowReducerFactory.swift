//
//  PaymentsTransfersFlowReducerFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 08.05.2024.
//

struct PaymentsTransfersFlowReducerFactory<LastPayment, Operator, UtilityService, Content, UtilityPaymentViewModel> {
    
    let makeUtilityPrepaymentState: MakeUtilityPrepaymentState
    let makeUtilityPaymentState: MakeUtilityPaymentState
    let makePaymentsViewModel: MakePaymentsViewModel
}

extension PaymentsTransfersFlowReducerFactory {
    
    typealias UtilityPrepaymentFlowEvent = UtilityPaymentFlowEvent<LastPayment, Operator, UtilityService>.UtilityPrepaymentFlowEvent
    typealias Payload = UtilityPrepaymentFlowEvent.UtilityPrepaymentPayload
    typealias MakeUtilityPrepaymentState = (Payload) -> UtilityPaymentFlowState<Operator, UtilityService, Content, UtilityPaymentViewModel>
    
    typealias Notify = (PaymentStateProjection) -> Void
    typealias MakeUtilityPaymentState = (AnywayTransactionState, @escaping Notify) -> UtilityServicePaymentFlowState<UtilityPaymentViewModel>
    
    typealias CloseAction = () -> Void
    typealias MakePaymentsViewModel = (@escaping CloseAction) -> PaymentsViewModel
}
