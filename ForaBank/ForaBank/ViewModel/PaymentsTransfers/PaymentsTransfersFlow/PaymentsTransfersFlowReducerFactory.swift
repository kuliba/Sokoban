//
//  PaymentsTransfersFlowReducerFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 08.05.2024.
//

struct PaymentsTransfersFlowReducerFactory<LastPayment, Operator, Service, Content, UtilityPaymentViewModel> {
    
    let makeUtilityPrepaymentState: MakeUtilityPrepaymentState
    let makeUtilityPaymentState: MakeUtilityPaymentState
    let makePaymentsViewModel: MakePaymentsViewModel
}

extension PaymentsTransfersFlowReducerFactory {
    
    typealias UtilityPrepaymentEvent = UtilityPrepaymentFlowEvent<LastPayment, Operator, Service>
    typealias Payload = UtilityPrepaymentEvent.Initiated.UtilityPrepaymentPayload
    typealias MakeUtilityPrepaymentState = (Payload) -> UtilityPaymentFlowState<Operator, Service, Content, UtilityPaymentViewModel>
    
    typealias Notify = (AnywayTransactionStatus) -> Void
    typealias MakeUtilityPaymentState = (AnywayTransactionState, @escaping Notify) -> UtilityServicePaymentFlowState<UtilityPaymentViewModel>
    
    typealias CloseAction = () -> Void
    typealias MakePaymentsViewModel = (@escaping CloseAction) -> PaymentsViewModel
}
