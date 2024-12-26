//
//  UtilityPrepaymentWrapperView.swift
//
//
//  Created by Igor Malyarov on 03.05.2024.
//

import FooterComponent
import SwiftUI
import TextFieldComponent
import UIPrimitives
import UtilityServicePrepaymentDomain
import UtilityServicePrepaymentUI

struct UtilityPrepaymentWrapperView: View {
    
    @ObservedObject private var viewModel: ViewModel
    @ObservedObject private var searchModel: RegularFieldViewModel
    
    private let completionEvent: (CompletionEvent) -> Void
    private let makeIconView: MakeIconView
    
    init(
        binder: Binder,
        completionEvent: @escaping (CompletionEvent) -> Void,
        makeIconView: @escaping MakeIconView
    ) {
        self.viewModel = binder.model
        self.searchModel = binder.searchModel
        self.completionEvent = completionEvent
        self.makeIconView = makeIconView
    }
    
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
    
    typealias MakeIconView = (String?) -> UIPrimitives.AsyncImage
    
    typealias LastPayment = UtilityPaymentLastPayment
    typealias Operator = UtilityPaymentProvider
    
    typealias CompletionEvent = UtilityPrepaymentCompletionEvent
    typealias ViewModel = UtilityPrepaymentViewModel
    
    typealias Binder = UtilityPrepaymentBinder
}

extension UtilityPaymentLastPayment: Identifiable {
    
    public var id: String { puref }
}

private extension UtilityPrepaymentWrapperView {
    
    func makeFooterView(
        isFailure: Bool
    ) -> some View {
        
        FooterView(
            state: isFailure ? .failure(.iVortex) : .footer(.iVortex),
            event: { completionEvent($0.event) },
            config: .iVortex
        )
    }
    
    func makeLastPaymentView(
        latestPayment: LastPayment
    ) -> some View {
        
        Button(
            action: { completionEvent(.select(.lastPayment(latestPayment))) },
            label: {

                LastPaymentLabel(
                    amount: "\(latestPayment.amount) ₽",
                    title: latestPayment.name,
                    config: .iVortex,
                    iconView: makeIconView(latestPayment.md5Hash)
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
                    subtitle: "ИНН \(`operator`.inn)",
                    config: .iVortex,
                    iconView: makeIconView(`operator`.icon)
                )
                .contentShape(Rectangle())
            }
        )
    }
    
    func makeSearchView() -> some View {
        
        DefaultCancellableSearchBarView(
            viewModel: searchModel,
            textFieldConfig: .black16,
            cancel: {
            
                UIApplication.shared.endEditing()
                searchModel.setText(to: nil)
            }
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
