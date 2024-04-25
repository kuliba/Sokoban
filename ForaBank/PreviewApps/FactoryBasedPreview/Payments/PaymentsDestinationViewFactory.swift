//
//  PaymentsDestinationViewFactory.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 25.04.2024.
//

import SwiftUI

struct PaymentsDestinationViewFactory<UtilityPrepaymentView>
where UtilityPrepaymentView: View {
    
    let makeUtilityPrepaymentView: MakeUtilityPrepaymentView
}

extension PaymentsDestinationViewFactory {
    
    typealias UtilityPrepaymentState = PrepaymentFlowState.Destination.UtilityPrepaymentState
    typealias MakeUtilityPrepaymentView = (UtilityPrepaymentState) -> UtilityPrepaymentView
}
