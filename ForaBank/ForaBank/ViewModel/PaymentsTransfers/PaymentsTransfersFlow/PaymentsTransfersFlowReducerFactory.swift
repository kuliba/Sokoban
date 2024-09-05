//
//  PaymentsTransfersFlowReducerFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 08.05.2024.
//

import AnywayPaymentDomain

struct PaymentsTransfersFlowReducerFactory {
    
    let getFormattedAmount: GetFormattedAmount
    let makeFraud: MakeFraudNoticePayload
    let makeUtilityPrepaymentState: MakeUtilityPrepaymentState
    let makeUtilityPaymentState: MakeUtilityPaymentState
    let makePayByInstructionsViewModel: MakePayByInstructionsViewModel
}

extension PaymentsTransfersFlowReducerFactory {
    
    typealias GetFormattedAmount = (ReducerState) -> String?
    
    typealias ReducerState = PaymentsTransfersViewModel.Route
    typealias MakeFraudNoticePayload = (ReducerState) -> FraudNoticePayload?
    
    typealias UtilityPrepaymentEvent = UtilityPrepaymentFlowEvent<UtilityPaymentLastPayment, UtilityPaymentOperator, UtilityService>
    typealias Payload = UtilityPrepaymentEvent.Initiated.UtilityPrepaymentPayload
    typealias MakeUtilityPrepaymentState = (Payload) -> UtilityPaymentFlowState<UtilityPaymentOperator, UtilityService, UtilityPrepaymentBinder>
    
    typealias Notify = (AnywayTransactionStatus?) -> Void
    typealias MakeUtilityPaymentState = (AnywayTransactionState.Transaction, @escaping Notify) -> UtilityServicePaymentFlowState
    
    typealias CloseAction = () -> Void
    typealias MakePayByInstructionsViewModel = (@escaping CloseAction) -> Node<PaymentsViewModel>
}
