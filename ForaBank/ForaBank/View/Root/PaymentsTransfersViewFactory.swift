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
    
    typealias _UtilityPaymentFlowState = UtilityPaymentFlowState<OperatorsListComponents.LatestPayment, OperatorsListComponents.Operator, UtilityService, UtilityPrepaymentViewModel, ObservingPaymentFlowMockViewModel>
    typealias _UtilityPaymentFlowEvent = UtilityPaymentFlowEvent<OperatorsListComponents.LatestPayment, OperatorsListComponents.Operator, UtilityService>
}
