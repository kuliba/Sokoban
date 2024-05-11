//
//  UtilityPrepaymentWrapperView.swift
//
//
//  Created by Igor Malyarov on 03.05.2024.
//

import FooterComponent
import OperatorsListComponents
import SwiftUI

struct UtilityPrepaymentWrapperView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    let flowEvent: (FlowEvent) -> Void
    let config: Config
    
    var body: some View {
        
        ComposedOperatorsView(
            state: viewModel.state,
            event: { viewModel.event($0.event) },
            factory: .init(
                makeFooterView: makeFooterView,
                makeLastPaymentView: makeLastPaymentView,
                makeOperatorView: makeOperatorView,
                makeSearchView: makeSearchView
            )
        )
        
        #warning("remove `ComposedUtilityPrepaymentView`")
//        ComposedUtilityPrepaymentView(
//            state: viewModel.state,
//            event: viewModel.event(_:),
//            flowEvent: flowEvent,
//            config: config
//        )
    }
}

extension UtilityPrepaymentWrapperView {
    
    typealias LastPayment = OperatorsListComponents.LastPayment
    typealias Operator = OperatorsListComponents.Operator<String>
    
    typealias FlowEvent = UtilityPrepaymentFlowEvent
    typealias ViewModel = UtilityPrepaymentViewModel
    typealias Config = ComposedUtilityPrepaymentView.Config
}

private extension UtilityPrepaymentWrapperView {
    
    func makeFooterView(
        isExpanded: Bool
    ) -> some View {
        
        FooterView(
            state: !isExpanded ? .footer(.iFora) : .failure(.iFora),
            event: { flowEvent($0.event) },
            config: .iFora
        )
    }
    
#warning("FIX ICON VIEW")
    func makeLastPaymentView(
        latestPayment: LastPayment
    ) -> some View {
        
        Button(
            action: { flowEvent(.select(.lastPayment(latestPayment))) },
            label: {
                
                LastPaymentLabel(
                    amount: latestPayment.amount,
                    title: latestPayment.title,
                    config: .iFora,
                    iconView: Text("TBD Icon View \(latestPayment)")
                )
                .contentShape(Rectangle())
            }
        )
    }
    
#warning("FIX ICON VIEW")
    func makeOperatorView(
        `operator`: Operator
    ) -> some View {
        
        Button(
            action: { flowEvent(.select(.operator(`operator`))) },
            label: {
                
                OperatorLabel(
                    title: `operator`.title,
                    subtitle: `operator`.subtitle,
                    config: .iFora,
                    iconView: Text("TBD Icon View \(`operator`)")
                )
                .contentShape(Rectangle())
            }
        )
    }
    
    func makeSearchView() -> some View {
        
        TextField(
            "Type to search",
            text: .init(
                get: { viewModel.state.searchText },
                set: { viewModel.event(.search(.entered($0))) }
            )
        )
    }
}

// MARK: - Adapters

private extension ComposedOperatorsEvent where OperatorID == String {
    
    var event: UtilityPrepaymentEvent {
        
        switch self {
        case let .didScrollTo(operatorID):
            return .didScrollTo(operatorID)
        }
    }
}

private extension FooterEvent {
    
    var event: UtilityPrepaymentFlowEvent {
        
        switch self {
        case .addCompany:
            return .addCompany
            
        case .payByInstruction:
            return .payByInstructions
        }
    }
}
