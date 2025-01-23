//
//  OperationPickerContentWrapperView.swift
//  Vortex
//
//  Created by Igor Malyarov on 23.01.2025.
//

import PayHubUI
import RxViewModel
import SwiftUI

struct OperationPickerContentWrapperView: View {
    
    let content: OperationPickerDomain.Content
    let select: (OperationPickerElement<Latest>) -> Void
    let config: Config
    
    var body: some View {
        
        RxWrapperView(
            model: content,
            makeContentView: { state, _ in
                
                OperationPickerContentView(
                    state: state,
                    select: select,
                    config: config.view,
                    itemLabel: operationPickerItemLabel
                )
            }
        )
    }
}

extension OperationPickerContentWrapperView {
    
    struct Config {
        
        let label: OperationPickerStateItemLabelConfig
        let latest: LatestPaymentButtonLabelConfig
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
            latestView: { latest in
                
                LatestPaymentButtonLabelView(
                    latest: latest,
                    config: config.latest
                )
            },
            placeholderView:  {
                
                LatestPlaceholder(opacity: 1, config: config.label.latestPlaceholder)
            }
        )
    }
}
