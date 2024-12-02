//
//  RootViewFactory+makeOperationPickerView.swift
//  ForaBank
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
                    itemLabel: itemLabel
                )
            }
        )
        .onFirstAppear { content.event(.load) }
    }
    
    private func itemLabel(
        item: OperationPickerState.Item
    ) -> some View {
        
        OperationPickerStateItemLabel(
            item: item,
            config: .iFora,
            placeholderView:  {
                
                LatestPlaceholder(
                    opacity: 1,
                    config: OperationPickerStateItemLabelConfig.iFora.latestPlaceholder
                )
            }
        )
    }
    
    @ViewBuilder
    private func makeDestinationView(
        destination: OperationPickerDomain.Navigation.Destination
    ) -> some View {
        
        switch destination {
        case let .exchange(currencyWalletViewModel):
            components.makeCurrencyWalletView(currencyWalletViewModel)
            
        case let .latest(latest):
            Text("TBD: destination " + String(describing: latest))
            
        case let .status(operationPickerFlowStatus):
            EmptyView()
        }
    }
}
