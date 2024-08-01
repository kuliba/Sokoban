//
//  PaymentsTransfersDestinationViewFactory.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 03.05.2024.
//

struct PaymentsTransfersDestinationViewFactory {
    
    let makeUtilityPrepaymentView: MakeUtilityPrepaymentView
}

extension PaymentsTransfersDestinationViewFactory {
    
    typealias MakeUtilityPrepaymentView = (UtilityPrepaymentViewModel) -> UtilityPrepaymentWrapperView
}
