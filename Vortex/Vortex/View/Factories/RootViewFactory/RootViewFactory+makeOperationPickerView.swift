//
//  RootViewFactory+makeOperationPickerView.swift
//  Vortex
//
//  Created by Igor Malyarov on 29.11.2024.
//

import PayHubUI
import RemoteServices
import RxViewModel
import SwiftUI
import UtilityServicePrepaymentUI

extension ViewComponents {
    
    @ViewBuilder
    func makeOperationPickerView(
        operationPicker: OperationPicker
    ) -> some View {
        
        OperationPickerView(
            operationPicker: operationPicker, 
            components: self,
            makeIconView: makeIconView
        )
    }
}

struct OperationPickerView: View {

    let operationPicker: OperationPicker
    let components: ViewComponents
    let makeIconView: MakeIconView

    var body: some View {
        
        if let binder = operationPicker.operationBinder {
            
            makeOperationPickerView(binder: binder)
            
        } else {
            
            Text("Unexpected operationPicker type \(String(describing: operationPicker))")
                .foregroundColor(.red)
        }
    }
}

extension OperationPickerView {
    
    private func makeOperationPickerView(
        binder: OperationPickerDomain.Binder
    ) -> some View {
        
        RxWrapperView(model: binder.flow) { state, event in
            
            OperationPickerFlowView(
                state: state,
                event: event,
                factory: .init(
                    makeContent: {
                        
                        makeContentView(binder.content)
                            .disabled(state.isLoading)
                    },
                    makeDestination: {
                        
                        makeDestinationView(
                            destination: $0,
                            closeAction: { binder.flow.event(.dismiss) }
                        )
                    }
                )
            )
        }
    }
    
    private func makeContentView(
        _ content: OperationPickerDomain.Content
    ) -> some View {
        
        OperationPickerContentWrapperView(
            content: content,
            select: { content.event(.select($0)) },
            config: .init(label: .prod, view: .prod(height: 96)),
            makeLastPaymentLabel: {
            
                LatestPaymentButtonLabelView(
                    latest: $0,
                    config: .prod()
                )
            }
        )
        .onFirstAppear { content.event(.load) }
    }
    
    @ViewBuilder
    private func makeDestinationView(
        destination: OperationPickerDomain.Navigation.Destination,
        closeAction: @escaping () -> Void
    ) -> some View {
        
        switch destination {
        case .exchangeFailure:
            EmptyView()
            
        case let .exchange(currencyWalletViewModel):
            components.makeCurrencyWalletView(currencyWalletViewModel)
            
        case let .latest(latest):
            switch latest {
            case let .anywayPayment(node):
                let payload = node.model.state.content.state.transaction.context.outline.payload
                
                components.makeAnywayFlowView(node.model)
                    .navigationBarWithAsyncIcon(
                        title: payload.title,
                        subtitle: payload.subtitle,
                        dismiss: closeAction,
                        icon: makeIconView(payload.icon.map { .md5Hash(.init($0)) }),
                        style: .normal
                    )
                
            case let .meToMe(meToMe):
                components.makePaymentsMeToMeView(meToMe)
                
            case let .payments(payments):
                components.makePaymentsView(payments)
            }
        }
    }
}

extension LatestPaymentButtonLabelView {
    
    init(
        latest: Latest,
        config: LatestPaymentButtonLabelConfig
    ) {
        self.init(label: latest.label, config: config)
    }
}
