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
        
        UtilityPaymentFlowView(
            state: state,
            event: { event(.prepayment($0)) },
            content: {
                
                UtilityPrepaymentWrapperView(
                    viewModel: state.content,
                    flowEvent: { event(.prepayment($0.flowEvent)) },
                    config: config
                )
            },
            destinationView: {
                
                utilityFlowDestinationView(state: $0, event: event)
            }
        )
    }
}

extension ComposedUtilityPaymentFlowView {
    
    typealias State = UtilityPaymentFlowState<OperatorsListComponents.LatestPayment, OperatorsListComponents.Operator, UtilityService, UtilityPrepaymentViewModel, ObservingPaymentFlowMockViewModel>
    typealias Event = UtilityPaymentFlowEvent<OperatorsListComponents.LatestPayment, OperatorsListComponents.Operator, UtilityService>
    
    typealias Config = UtilityPrepaymentViewConfig
}

private extension ComposedUtilityPaymentFlowView {
    
    @ViewBuilder
    func utilityFlowDestinationView(
        state: State.Destination,
        event: @escaping (Event) -> Void
    ) -> some View {
     
        Text("TBD: destination")
    }
}

private extension UtilityPrepaymentFlowEvent {
    
    var flowEvent: UtilityPaymentFlowEvent<OperatorsListComponents.LatestPayment, OperatorsListComponents.Operator, UtilityService>.UtilityPrepaymentFlowEvent {
        
        switch self {
        case .addCompany:
            return .addCompany
            
        case .payByInstructions:
            return .payByInstructions
            
        case .payByInstructionsFromError:
            return .payByInstructionsFromError
            
        case let .select(select):
            switch select {
            case let .lastPayment(lastPayment):
                return .select(.lastPayment(lastPayment))
                
            case let .operator(`operator`):
                return .select(.operator(`operator`))
            }
        }
    }
}
