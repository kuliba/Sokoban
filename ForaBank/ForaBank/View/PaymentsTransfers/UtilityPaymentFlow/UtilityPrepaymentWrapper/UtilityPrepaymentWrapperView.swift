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
    
    let completionEvent: (CompletionEvent) -> Void
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
    
    typealias CompletionEvent = UtilityPrepaymentCompletionEvent
    typealias ViewModel = UtilityPrepaymentViewModel
}

private extension UtilityPrepaymentWrapperView {
    
    func makeFooterView(
        isFailure: Bool
    ) -> some View {
        
        FooterView(
            state: isFailure ? .failure(.iFora) : .footer(.iFora),
            event: { completionEvent($0.event) },
            config: .iFora
        )
    }
    
    func makeLastPaymentView(
        latestPayment: LastPayment
    ) -> some View {
        
        Button(
            action: { completionEvent(.select(.lastPayment(latestPayment))) },
            label: {
                #warning("md5Hash is unwrapped to empty - iconView should be able to deal with it at composition level")
                LastPaymentLabel(
                    amount: "\(latestPayment.amount)",
                    title: latestPayment.name,
                    config: .iFora,
                    iconView: makeIconView(latestPayment.md5Hash ?? "")
                )
                .contentShape(Rectangle())
            }
        )
    }
    
    func makeOperatorView(
        `operator`: Operator
    ) -> some View {
        
        Button(
            action: { completionEvent(.select(.operator(`operator`))) },
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
            "Наименование или ИНН",
            text: .init(
                get: { viewModel.state.searchText },
                set: { viewModel.event(.search($0)) }
            )
        )
        .frame(height: 44)
        .padding(.leading, 14)
        .padding(.trailing, 15)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.bordersDivider, lineWidth: 1)
        )
    }
}

// MARK: - Adapters

private extension FooterEvent {
    
    var event: UtilityPrepaymentCompletionEvent {
        
        switch self {
        case .addCompany:
            return .addCompany
            
        case .payByInstruction:
            return .payByInstructions
        }
    }
}
