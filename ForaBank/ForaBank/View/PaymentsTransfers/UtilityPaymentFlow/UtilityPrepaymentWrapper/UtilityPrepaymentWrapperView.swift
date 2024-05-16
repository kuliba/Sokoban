//
//  UtilityPrepaymentWrapperView.swift
//
//
//  Created by Igor Malyarov on 03.05.2024.
//

import FooterComponent
import SwiftUI
import UIPrimitives
import UtilityServicePrepaymentDomain
import UtilityServicePrepaymentUI

struct UtilityPrepaymentWrapperView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    let flowEvent: (FlowEvent) -> Void
    let makeIconView: MakeIconView
    
    var body: some View {
        
        PrepaymentPicker(
            state: viewModel.state,
            event: { viewModel.event($0) },
            factory: .init(
                makeFooterView: makeFooterView,
                makeLastPaymentView: makeLastPaymentView,
                makeOperatorView: makeOperatorView,
                makeSearchView: makeSearchView
            )
        )
    }
}

extension UtilityPrepaymentWrapperView {
    
    typealias MakeIconView = (String) -> UIPrimitives.AsyncImage
    
    typealias LastPayment = UtilityPaymentLastPayment
    typealias Operator = UtilityPaymentOperator
    
    typealias FlowEvent = UtilityPrepaymentFlowEvent
    typealias ViewModel = UtilityPrepaymentViewModel
}

private extension UtilityPrepaymentWrapperView {
    
    func makeFooterView(
        isFailure: Bool
    ) -> some View {
        
        FooterView(
            state: isFailure ? .failure(.iFora) : .footer(.iFora),
            event: { flowEvent($0.event) },
            config: .iFora
        )
    }
    
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
                    iconView: makeIconView(latestPayment.icon)
                )
                .contentShape(Rectangle())
            }
        )
    }
    
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
                    iconView: makeIconView(`operator`.icon)
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
                set: { viewModel.event(.search($0)) }
            )
        )
    }
}

// MARK: - Adapters

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
