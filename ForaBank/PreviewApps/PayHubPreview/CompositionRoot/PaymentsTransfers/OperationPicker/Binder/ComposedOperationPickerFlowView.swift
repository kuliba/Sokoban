//
//  ComposedOperationPickerFlowView.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 24.08.2024.
//

import PayHubUI
import SwiftUI

struct ComposedOperationPickerFlowView: View {
    
    let binder: OperationPickerBinder
    
    var body: some View {
        
        OperationPickerFlowView(
            binder: binder,
            factory: .init(
                makeContent: makeOperationPickerContentView,
                makeDestination: { Text("TBD: destination " + String(describing: $0)) }
            )
        )
    }
}

private extension ComposedOperationPickerFlowView {
    
    func makeOperationPickerContentView(
        _ content: OperationPickerContent
    ) -> some View {
        
        OperationPickerContentWrapperView(
            model: content,
            makeContentView: { state, event in
                
                OperationPickerContentView(
                    state: state,
                    event: event,
                    config: .preview,
                    itemLabel: {
                        
                        OperationPickerStateItemLabel(
                            item: $0,
                            config: .preview,
                            placeholderView:  {
                                
                                LatestPlaceholder(
                                    opacity: 1,
                                    config: OperationPickerStateItemLabelConfig.preview.latestPlaceholder
                                )
                            }
                        )
                    }
                )
            }
        )
    }

}
