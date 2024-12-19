//
//  RootViewFactory+makeOperationPickerView.swift
//  Vortex
//
//  Created by Igor Malyarov on 29.11.2024.
//

import PayHubUI
import RxViewModel
import SwiftUI

extension RootViewFactory {
    
    @ViewBuilder
    func makeOperationPickerView(
        operationPicker: PayHubUI.OperationPicker
    ) -> some View {
        
        if let binder = operationPicker.operationBinder {
            
            makeOperationPickerView(binder: binder)
            
        } else {
            
            Text("Unexpected operationPicker type \(String(describing: operationPicker))")
                .foregroundColor(.red)
        }
    }
    
    private func makeOperationPickerView(
        binder: OperationPickerDomain.Binder
    ) -> some View {
        
        RxWrapperView(
            model: binder.flow,
            makeContentView: {
                
                OperationPickerFlowView(
                    state: $0,
                    event: $1,
                    factory: .init(
                        makeContent: { makeContentView(binder.content) },
                        makeDestination: makeDestinationView
                    )
                )
            }
        )
    }
    
    private func makeContentView(
        _ content: OperationPickerContent
    ) -> some View {
        
        RxWrapperView(
            model: content,
            makeContentView: { state, event in
                
                OperationPickerContentView(
                    state: state,
                    event: event,
                    config: .prod,
                    itemLabel: operationPickerItemLabel
                )
            }
        )
        .onFirstAppear { content.event(.load) }
    }
    
    private func operationPickerItemLabel(
        item: OperationPickerState.Item
    ) -> some View {
        
        OperationPickerStateItemLabel(
            item: item,
            config: .iVortex,
            latestView: { latest in
                
                LatestPaymentButtonLabelView(latest: latest, config: .prod())
            },
            placeholderView:  {
                
                LatestPlaceholder(
                    opacity: 1,
                    config: OperationPickerStateItemLabelConfig.iVortex.latestPlaceholder
                )
            }
        )
    }
    
    @ViewBuilder
    private func makeDestinationView(
        destination: OperationPickerDomain.Navigation.Destination
    ) -> some View {
        
        switch destination {
        case .exchangeFailure:
            EmptyView()
            
        case let .exchange(currencyWalletViewModel):
            components.makeCurrencyWalletView(currencyWalletViewModel)
            
        case let .latest(latest):
            Text("TBD: destination " + String(describing: latest))
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

private extension Latest {
    
    var label: LatestPaymentButtonLabel {
        
        switch self {
        case let .service(service):
            return service.label
            
        case let .withPhone(withPhone):
            return withPhone.label
        }
    }
}

// LatestPaymentsViewComponent.swift:204

private extension Latest.Service {
    
    var label: LatestPaymentButtonLabel {
        
        return .init(
            amount: amount.map(String.init), 
            avatar: .text(name ?? lpName ?? ""),
            description: "",
            topIcon: nil
        )
    }
}

private extension Latest.WithPhone {
    
    var label: LatestPaymentButtonLabel {
        
        return .init(
            amount: amount.map(String.init),
            avatar: .text(name ?? ""),
            description: "",
            topIcon: nil
        )
    }
}
