//
//  PaymentsTransfersViewFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 10.05.2024.
//

import OperatorsListComponents

struct PaymentsTransfersViewFactory {
    
    let makeSberQRConfirmPaymentView: MakeSberQRConfirmPaymentView
    let makeUserAccountView: MakeUserAccountView
}

extension PaymentsTransfersViewFactory {
    
    typealias LastPayment = OperatorsListComponents.LastPayment
    typealias Operator = OperatorsListComponents.Operator<String>
    
    typealias _UtilityPaymentFlowState = UtilityPaymentFlowState<LastPayment, Operator, UtilityService, UtilityPrepaymentViewModel, ObservingPaymentFlowMockViewModel>
    typealias _UtilityPaymentFlowEvent = UtilityPaymentFlowEvent<LastPayment, Operator, UtilityService>
}
