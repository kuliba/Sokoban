//
//  RootViewFactory+makeOperationPickerView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 29.11.2024.
//

import PayHubUI
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
    
    func makeOperationPickerView(
        binder: OperationPickerDomain.Binder
    ) -> some View {
        
        ComposedOperationPickerFlowView(
            binder: binder,
            factory: .init(
                makeDestinationView: makeOperationPickerDestinationView,
                makeItemLabel: itemLabel
            )
        )
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
}
