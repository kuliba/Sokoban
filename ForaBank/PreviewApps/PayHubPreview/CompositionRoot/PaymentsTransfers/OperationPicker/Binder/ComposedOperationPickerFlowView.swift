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
        
        OperationPickerFlowWrapperView(
            model: binder.flow,
            makeContentView: {
                
                OperationPickerFlowView(
                    state: $0,
                    event: $1,
                    factory: .init(
                        makeContent: {
                            
                            makeContentView(binder.content)
                        },
                        makeDestination: {
                            
                            Text("TBD: destination " + String(describing: $0))
                        }
                    )
                )
            }
        )
    }
}

private extension ComposedOperationPickerFlowView {
    
    func makeContentView(
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
        .onFirstAppear { content.event(.load) }
    }

}
