//
//  OperationPickerContentWrapperView.swift
//  Vortex
//
//  Created by Igor Malyarov on 23.01.2025.
//

import PayHubUI
import RxViewModel
import SwiftUI
import UtilityServicePrepaymentUI

struct OperationPickerContentWrapperView<LastPaymentLabel: View>: View {
    
    let content: OperationPickerDomain.Content
    let select: (OperationPickerElement<Latest>) -> Void
    let config: Config
    let makeLastPaymentLabel: (Latest) -> LastPaymentLabel

    var body: some View {
        
        RxWrapperView(
            model: content,
            makeContentView: { state, _ in
                
                if !state.items.isEmpty {
                
                    OperationPickerContentView(
                        state: state,
                        select: select,
                        config: config.view,
                        itemLabel: operationPickerItemLabel
                    )
                }
            }
        )
    }
}

extension OperationPickerContentWrapperView {
    
    struct Config {
        
        let label: OperationPickerStateItemLabelConfig
        let view: OperationPickerContentViewConfig
    }
}

private extension OperationPickerContentWrapperView {
    
    func operationPickerItemLabel(
        item: OperationPickerState.Item
    ) -> some View {
        
        OperationPickerStateItemLabel(
            item: item,
            config: config.label,
            latestView: makeLastPaymentLabel,
            placeholderView: placeholderView
        )
    }
    
    func placeholderView() -> some View {
        
        LatestPlaceholder(opacity: 1, config: config.label.latestPlaceholder)
    }
}
