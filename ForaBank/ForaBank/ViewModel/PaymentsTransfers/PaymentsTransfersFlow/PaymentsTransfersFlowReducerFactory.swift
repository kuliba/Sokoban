//
//  PaymentsTransfersFlowReducerFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 08.05.2024.
//

import AnywayPaymentDomain

struct PaymentsTransfersFlowReducerFactory<LastPayment, Operator, Service, Content, PaymentViewModel> {
    
    let getFormattedAmount: GetFormattedAmount
    let makeFraud: MakeFraudNoticePayload
    let makeUtilityPrepaymentState: MakeUtilityPrepaymentState
    let makeUtilityPaymentState: MakeUtilityPaymentState
    let makePayByInstructionsViewModel: MakePayByInstructionsViewModel
}

extension PaymentsTransfersFlowReducerFactory {
    
    typealias GetFormattedAmount = (ReducerState) -> String?
    
    typealias ReducerState = PaymentsTransfersViewModel._Route<Operator, Service, Content, PaymentViewModel>
    typealias MakeFraudNoticePayload = (ReducerState) -> FraudNoticePayload?
    
    typealias UtilityPrepaymentEvent = UtilityPrepaymentFlowEvent<LastPayment, Operator, Service>
    typealias Payload = UtilityPrepaymentEvent.Initiated.UtilityPrepaymentPayload
    typealias MakeUtilityPrepaymentState = (Payload) -> UtilityPaymentFlowState<Operator, Service, Content, PaymentViewModel>
    
    typealias Notify = (AnywayTransactionStatus?) -> Void
    typealias MakeUtilityPaymentState = (AnywayTransactionState.Transaction, @escaping Notify) -> UtilityServicePaymentFlowState<PaymentViewModel>
    
    typealias CloseAction = () -> Void
    typealias MakePayByInstructionsViewModel = (@escaping CloseAction) -> PaymentsViewModel
}
