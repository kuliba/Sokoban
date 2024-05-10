//
//  ComposedUtilityPaymentFlowView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 10.05.2024.
//

import OperatorsListComponents
import SwiftUI

struct ComposedUtilityPaymentFlowView: View {
    
    let state: State
    let event: (Event) -> Void
    let config: Config

    var body: some View {
        
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

extension ComposedUtilityPaymentFlowView {
    
    typealias State = UtilityPaymentFlowState<OperatorsListComponents.LatestPayment, OperatorsListComponents.Operator, UtilityService, UtilityPrepaymentViewModel, ObservingPaymentFlowMockViewModel>
    typealias Event = UtilityPaymentFlowEvent<OperatorsListComponents.LatestPayment, OperatorsListComponents.Operator, UtilityService>
    
    typealias Config = UtilityPrepaymentViewConfig
}
