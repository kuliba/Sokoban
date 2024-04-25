//
//  PaymentsDestinationViewFactory.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 25.04.2024.
//

struct PaymentsDestinationViewFactory {
    
    let makeUtilityPrepaymentView: MakeUtilityPrepaymentView
}

extension PaymentsDestinationViewFactory {
    
    typealias UtilityPrepaymentState = PrepaymentFlowState.Destination.UtilityPrepaymentState
    typealias MakeUtilityPrepaymentView = (UtilityPrepaymentState) -> UtilityPrepaymentView
}
